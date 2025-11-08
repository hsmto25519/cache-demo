mod cache;
mod db;
mod models;

use anyhow::{Context, Result, Error};
use dotenvy::dotenv;
use std::env;
use cache::RedisCache;
use db::PostgresRepo;

use crate::models::User;

async fn run_service(
    db: &PostgresRepo,
    cache: &RedisCache,
    username: &str,
) -> Result<()> {
    
    // --- PostgreSQL (Persistence Layer) ---
    println!("\n[PostgreSQL] Attempting to get or create user: {}", username);
    
    // Use the Postgres "object" to handle DB logic
    let user = db.get_or_create_user(username).await?;
    
    println!(
        "[PostgreSQL] Fetched data: ID={}, Username='{}', CreatedAt={:?}",
        user.id,
        user.username,
        user.created_at
    );

    // --- Redis (Caching/Volatile Layer) ---
    // Using the hardcoded values from the original example
    println!("\n[Redis] Performing SET/GET operations (original example)...");

    // 1. Set a value using the cache "object"
    cache.set_value(&user.username, &user.to_json().unwrap()).await?;
    println!("[Redis] SET '{}' successfully.", &user.username);

    // 2. Get the value
    let retrieved_value = cache.get_value(&user.username).await?;
    println!("[Redis] GET value: '{}'", retrieved_value);

    // 3. Verify
    assert_eq!(retrieved_value, user.to_json().unwrap(), "Redis value mismatch");

    // --- Caching the actual user data (as requested) ---
    // This demonstrates passing the input value to both systems.
    let user_cache_key = format!("user_profile: {}", user.username);
    // let user_cache_value = format!("id:{},created_at:{:?}", user.id, user.created_at);
    let user_cache_value = user.to_json()?;

    println!("\n[Redis] Caching the user data we fetched from Postgres...");
    cache.set_value(&user_cache_key, &user_cache_value).await?;
    println!("[Redis] SET '{}' successfully.", user_cache_key);

    let cached_user_data = cache.get_value(&user_cache_key).await?;
    println!("[Redis] GET value: '{}'", cached_user_data);
    assert_eq!(cached_user_data, user_cache_value);

    Ok(())
}

/// implement 'cache aside pattern'
async fn read_target_user(
    db: &PostgresRepo,
    cache: &RedisCache,
    username: &str,
) -> Result<String, Error> {
    
    // 1. Retrieve the target value from the cache if it exists.
    let cache_result = match cache.get_value(username).await {
        Ok(retrieved_value) => Some(retrieved_value),
        Err(_) => {
            println!("\ncan't get the data from the cache store.");
            None
            // return Err(e);
        }
    };

    // return the value if the value exists.
    if let Some(value) = cache_result {
        return Ok(value)
        // println!("ret value: {}", value);
    } 

    // 2. access database
    println!("\naccess the database...");
    let db_result = match db.get_user(username).await {
        Ok(data) => data,
        Err(e) => {
            // there is no user.
            // eprintln!("[Error] can't get the data for {}: {:?}", username, e);
            return Err(e);
        }
    };

    // 3. update cache store.
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

    println!("[PostgreSQL] Connecting to persistence layer...");
    let db_repo = PostgresRepo::connect(&db_url).await?;
    println!("[PostgreSQL] Connection successful.");

    println!("\n[Redis] Connecting to volatile cache layer...");
    let cache = RedisCache::connect(&redis_url).await?;
    println!("[Redis] Connection successful.");

    println!("Start functions!!");
    
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

    // match run_service(&db_repo, &cache, &input_value).await {
    //     Ok(_) => println!("\nService completed successfully!"),
    //     Err(e) => {
    //         eprintln!("\nERROR: Service failed to run.");
    //         eprintln!("Details: {:?}", e);
    //         return Err(e);
    //     }
    // }

    Ok(())
}