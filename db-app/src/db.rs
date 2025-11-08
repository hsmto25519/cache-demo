use crate::models::User;
use anyhow::{Context, Result};
use sqlx::{postgres::PgPoolOptions, PgPool};
use chrono::{DateTime, Utc};

/// The "Postgres object" (Repository).
/// It holds the connection pool.
#[derive(Debug)]
pub struct PostgresRepo {
    pool: PgPool,
}

impl PostgresRepo {
    /// Creates a new PostgresRepo with a connection pool.
    pub async fn connect(db_url: &str) -> Result<Self> {
        let pool = PgPoolOptions::new()
            .max_connections(5)
            .connect(db_url)
            .await
            .context("Failed to connect to PostgreSQL database")?;
        
        Ok(Self { pool })
    }

    pub async fn get_user(&self, username: &str) -> Result<User> {
        let user = sqlx::query_as!(
            User,
            "SELECT id, username, created_at as \"created_at: DateTime<Utc>\" FROM users WHERE username = $1",
            username
        )
        .fetch_one(&self.pool)
        .await
        .context("Failed to read user data")?;

        Ok(user)
    }

    /// A combined function to handle the original logic.
    /// It inserts the user if they don't exist, then fetches and returns them.
    pub async fn get_or_create_user(&self, username: &str) -> Result<User> {
        
        // 1. Insert a user if the user doesnt exist in the database.
        let insert_result = sqlx::query!(
            "INSERT INTO users (username) VALUES ($1) ON CONFLICT (username) DO NOTHING",
            username
        )
        .execute(&self.pool)
        .await
        .context("Failed to insert data into 'users' table")?;

        if insert_result.rows_affected() > 0 {
            println!("[PostgreSQL] Inserted new user: {}", username);
        } else {
            println!("[PostgreSQL] User '{}' already exists. Skipping insertion.", username);
        }

        // 2. Read the user
        self.get_user(username).await
    }
}