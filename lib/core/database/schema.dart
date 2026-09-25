final class Migration {
  const Migration(this.version, this.statements);

  final int version;
  final List<String> statements;
}

const databaseVersion = 1;

const migrations = <Migration>[
  Migration(1, [
    '''CREATE TABLE genres (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, memo TEXT NOT NULL DEFAULT '',
      archived INTEGER NOT NULL DEFAULT 0)''',
    '''CREATE TABLE characters (
      id TEXT PRIMARY KEY, genre_id TEXT NOT NULL, name TEXT NOT NULL,
      memo TEXT NOT NULL DEFAULT '', default_lens_product_id TEXT,
      archived INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (genre_id) REFERENCES genres(id))''',
    '''CREATE TABLE costumes (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, is_general INTEGER NOT NULL,
      character_id TEXT, memo TEXT NOT NULL DEFAULT '', archived INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (character_id) REFERENCES characters(id))''',
    '''CREATE TABLE contact_lenses (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, manufacturer TEXT NOT NULL,
      color TEXT NOT NULL, wear_type TEXT NOT NULL, open_period_days INTEGER,
      memo TEXT NOT NULL DEFAULT '', archived INTEGER NOT NULL DEFAULT 0)''',
    '''CREATE TABLE character_lenses (
      character_id TEXT NOT NULL, lens_product_id TEXT NOT NULL,
      is_default INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (character_id, lens_product_id))''',
    '''CREATE TABLE lens_purchases (
      id TEXT PRIMARY KEY, lens_product_id TEXT NOT NULL, purchased_on TEXT NOT NULL,
      unopened_expires_on TEXT, quantity INTEGER NOT NULL CHECK(quantity >= 0))''',
    '''CREATE TABLE lens_inventory (
      id TEXT PRIMARY KEY, purchase_id TEXT NOT NULL, opened_on TEXT,
      disposed INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (purchase_id) REFERENCES lens_purchases(id))''',
    '''CREATE TABLE diary (
      id TEXT PRIMARY KEY, activity_date TEXT NOT NULL, activity_type TEXT NOT NULL,
      genre_id TEXT, character_id TEXT, costume_id TEXT, memo TEXT NOT NULL DEFAULT '',
      photo_id TEXT, lens_inventory_id TEXT, created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL)''',
    '''CREATE TABLE lens_usage (
      id TEXT PRIMARY KEY, diary_id TEXT NOT NULL UNIQUE,
      inventory_id TEXT NOT NULL, used_on TEXT NOT NULL,
      FOREIGN KEY (diary_id) REFERENCES diary(id) ON DELETE CASCADE)''',
    '''CREATE TABLE photos (
      id TEXT PRIMARY KEY, relative_path TEXT NOT NULL UNIQUE,
      original_name TEXT NOT NULL, width INTEGER, height INTEGER,
      created_at TEXT NOT NULL)''',
    '''CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)''',
    'CREATE INDEX diary_activity_date_idx ON diary(activity_date)',
    'CREATE INDEX lens_usage_inventory_idx ON lens_usage(inventory_id)',
  ]),
];
