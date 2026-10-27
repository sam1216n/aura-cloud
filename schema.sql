-- Migração idempotente: não apaga dados existentes.
CREATE TABLE IF NOT EXISTS chats (
  id TEXT PRIMARY KEY, title TEXT NOT NULL, model TEXT NOT NULL,
  created INTEGER NOT NULL, updated INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS messages (
  id TEXT PRIMARY KEY, chat_id TEXT NOT NULL, role TEXT NOT NULL,
  content TEXT NOT NULL, created INTEGER NOT NULL,
  FOREIGN KEY(chat_id) REFERENCES chats(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_messages_chat ON messages(chat_id, created);
CREATE INDEX IF NOT EXISTS idx_chats_updated ON chats(updated DESC);
CREATE TABLE IF NOT EXISTS usage (
  day TEXT PRIMARY KEY, count INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS login_attempts (
  subject TEXT PRIMARY KEY, count INTEGER NOT NULL DEFAULT 0,
  reset_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS artifacts (
 id TEXT PRIMARY KEY, chat_id TEXT NOT NULL, title TEXT NOT NULL,
 files TEXT NOT NULL, created INTEGER NOT NULL,
 FOREIGN KEY(chat_id) REFERENCES chats(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_artifacts_chat ON artifacts(chat_id);

-- AURA 4.0: account-isolated namespace. Legacy tables are retained, not assigned
-- to any Google user. This deliberately avoids exposing older shared records.
CREATE TABLE IF NOT EXISTS v4_users (
 id TEXT PRIMARY KEY, google_sub TEXT NOT NULL UNIQUE, email TEXT NOT NULL,
 name TEXT NOT NULL, avatar TEXT, created INTEGER NOT NULL, updated INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS v4_oauth_states (
 state_hash TEXT PRIMARY KEY, verifier TEXT NOT NULL, nonce TEXT NOT NULL, expires INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS v4_sessions (
 token_hash TEXT PRIMARY KEY, user_id TEXT NOT NULL, expires INTEGER NOT NULL,
 created INTEGER NOT NULL, FOREIGN KEY(user_id) REFERENCES v4_users(id)
);
CREATE INDEX IF NOT EXISTS idx_v4_sessions_user ON v4_sessions(user_id);
CREATE TABLE IF NOT EXISTS v4_chats (
 id TEXT PRIMARY KEY, user_id TEXT NOT NULL, title TEXT NOT NULL, model TEXT NOT NULL,
 created INTEGER NOT NULL, updated INTEGER NOT NULL,
 FOREIGN KEY(user_id) REFERENCES v4_users(id)
);
CREATE INDEX IF NOT EXISTS idx_v4_chats_owner_updated ON v4_chats(user_id,updated DESC);
CREATE TABLE IF NOT EXISTS v4_messages (
 id TEXT PRIMARY KEY, user_id TEXT NOT NULL, chat_id TEXT NOT NULL,
 role TEXT NOT NULL, content TEXT NOT NULL, created INTEGER NOT NULL,
 FOREIGN KEY(user_id) REFERENCES v4_users(id),
 FOREIGN KEY(chat_id) REFERENCES v4_chats(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_v4_messages_owner_chat ON v4_messages(user_id,chat_id,created);
CREATE TABLE IF NOT EXISTS v4_artifacts (
 id TEXT PRIMARY KEY, user_id TEXT NOT NULL, chat_id TEXT NOT NULL,
 title TEXT NOT NULL,files TEXT NOT NULL,created INTEGER NOT NULL,
 FOREIGN KEY(user_id) REFERENCES v4_users(id),
 FOREIGN KEY(chat_id) REFERENCES v4_chats(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_v4_artifacts_owner ON v4_artifacts(user_id,chat_id);
CREATE TABLE IF NOT EXISTS v4_usage (
 user_id TEXT NOT NULL, day TEXT NOT NULL, count INTEGER NOT NULL DEFAULT 0,
 PRIMARY KEY(user_id,day)
);
CREATE TABLE IF NOT EXISTS v4_global_usage (
 day TEXT PRIMARY KEY, count INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS v4_images (
 id TEXT PRIMARY KEY, user_id TEXT NOT NULL, chat_id TEXT NOT NULL,
 prompt TEXT NOT NULL, mime TEXT NOT NULL, object_key TEXT NOT NULL,
 created INTEGER NOT NULL,
 FOREIGN KEY(user_id) REFERENCES v4_users(id),
 FOREIGN KEY(chat_id) REFERENCES v4_chats(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_v4_images_owner_created ON v4_images(user_id,created DESC);
CREATE INDEX IF NOT EXISTS idx_v4_images_owner_chat ON v4_images(user_id,chat_id);

-- AURA 5.0: autenticacao local. Todas as tabelas v4 de chats/mensagens/imagens
-- permanecem e continuam referenciando v4_users.id. Sem DROP/DELETE de dados.
-- google_sub recebe um identificador sintetico local:<uuid> para respeitar
-- o schema antigo sem vincular automaticamente contas Google a novas contas.
CREATE TABLE IF NOT EXISTS v5_credentials (
 user_id TEXT PRIMARY KEY,
 username_key TEXT NOT NULL UNIQUE,
 password_hash TEXT NOT NULL,
 salt TEXT NOT NULL,
 iterations INTEGER NOT NULL,
 created INTEGER NOT NULL,
 updated INTEGER NOT NULL,
 FOREIGN KEY(user_id) REFERENCES v4_users(id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_v5_credentials_username ON v5_credentials(username_key);
CREATE TABLE IF NOT EXISTS v5_rate_limits (
 key TEXT PRIMARY KEY,
 count INTEGER NOT NULL DEFAULT 0,
 reset_at INTEGER NOT NULL
);
