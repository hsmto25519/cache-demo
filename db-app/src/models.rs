use anyhow::{Context, Result};
use chrono::{DateTime, Utc};
use sqlx::FromRow;
use serde::Serialize;

/// for the 'users' table.
#[derive(Debug, FromRow, Serialize)]
pub struct User {
    pub id: i32,
    pub username: String,
    pub created_at: DateTime<Utc>, // Works with TIMESTAMPTZ
}

impl User {
    /// Serializes the User struct into a JSON string.
    pub fn to_json(&self) -> Result<String> {
        serde_json::to_string(self)
            .context("Failed to serialize User struct to JSON")
    }
}