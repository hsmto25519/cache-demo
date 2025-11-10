mod cache;
mod db;
mod models;

use anyhow::{Context, Result, Error};
use dotenvy::dotenv;
use std::env;
use cache::RedisCache;
use db::PostgresRepo;

/// implement 'cache aside pattern'
async fn read_target_user(
    db: &PostgresRepo,
    cache: &RedisCache,
    username: &str,
) -> Result<String, Error> {
    
    // 1. Retrieve the target value from the cache if it exists.
    let cache_result = match cache.get_value(username).await {
        Ok(retrieved_value) => {
            println!("\ncache hit!!!");
            Some(retrieved_value)
        },
        Err(_) => {
            println!("\ncan't get the data from the cache store.");
            None
        }
    };

    // return the value if the value exists.
    if let Some(value) = cache_result {
        return Ok(value);
    } 

    // 2. Access the database
    println!("\naccess the database...");
    let db_result = match db.get_user(username).await {
        Ok(data) => data,
        Err(e) => {
            // there is no user.
            return Err(e);
        }
    };

    // 3. Update the cache store.
    println!("\nset the value in the cache store.");
    cache.set_value(&username, &db_result.to_json().unwrap()).await?;

    Ok(db_result.to_json()?)
}

/// implement 'write through pattern'
async fn write_target_user(
    db: &PostgresRepo,
    cache: &RedisCache,
    username: &str,
) -> Result<String, Error> {

    // update the database.
    println!("\naccess the database...");
    let user = db.get_or_create_user(username).await?;
    let user_json = user.to_json().unwrap();

    // set the value in the cache store.
    println!("\nset the data in the cache store...");
    cache.set_value(username, &user_json).await?;
    
    Ok(user_json)
}

#[tokio::main]
async fn main() -> Result<()> {
    dotenv().ok();
    println!("The env variables are read.");

    let db_url = env::var("DATABASE_URL").context("DATABASE_URL must be set")?;
    let redis_url = env::var("REDIS_URL").context("REDIS_URL must be set")?;

    println!("input username:");
    let mut input_value = String::new();
    std::io::stdin().read_line(&mut input_value).expect("Failed to read line");

    // shadowing 'input_value to remove '\n' in the end of the variable
    let input_value = input_value.trim();

    let db_repo = PostgresRepo::connect(&db_url).await?;
    let cache = RedisCache::connect(&redis_url).await?;

    println!("---Start functions!!---");
    
    println!("read_target_user() started.");
    let target_user = match read_target_user(&db_repo, &cache, &input_value).await {
        Ok(result) => result,
        Err(e) => {
            eprintln!("\nERROR: failed to read the user.");
            eprintln!("Details: {:?}", e);
            "nodata".to_string()
        }
    };
    println!("read_target_user() executed successfully.");
    println!("the user is {}", target_user);
    println!("----------------------------------");

    println!("write_target_user() started");
    let target_user = match write_target_user(&db_repo, &cache, &input_value).await {
        Ok(result) => result,
        Err(e) => {
            eprintln!("\nERROR: failed to write the user.");
            eprintln!("Details: {:?}", e);
            return Err(e);
        }
    };
    println!("write_target_user() executed successfully.");
    println!("the user is {}", target_user);
    println!("----------------------------------");

    Ok(())
}