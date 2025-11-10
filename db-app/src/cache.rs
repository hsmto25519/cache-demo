use anyhow::{Context, Result};
use redis::{AsyncCommands, Client};

/// The "Redis object" (Cache).
/// It holds a connection manager, which is cloneable and thread-safe.
#[derive(Debug, Clone)]
pub struct RedisCache {
    con: redis::aio::MultiplexedConnection,
}

impl RedisCache {
    /// Creates a new RedisCache with a connection manager.
    pub async fn connect(redis_url: &str) -> Result<Self> {
        let client = Client::open(redis_url)
            .context("Failed to create Redis client. Check URL format.")?;

        let con = client.get_multiplexed_async_connection().await
            .context("Failed to connect to Redis server (ConnectionManager).")?;
        
        Ok(Self { con })
    }

    /// Set a value in Redis.
    /// It gets a connection from the pool by cloning the manager.
    pub async fn set_value(&self, key: &str, value: &str) -> Result<()> {
        let mut con = self.con.clone();
        let () = con.set(key, value).await.context("Redis SET command failed")?;
        Ok(())
    }

    /// Get a value from Redis.
    pub async fn get_value(&self, key: &str) -> Result<String> {
        let mut con = self.con.clone();
        let retrieved_value: String = con.get(key).await.context("Redis GET command failed")?;
        Ok(retrieved_value)
    }
}