# Supabase Setup for BMI Tracker

## 1. Create the bmi_records Table

Go to your Supabase Dashboard → SQL Editor and run:

```sql
-- Open supabase-migration.sql and execute it, OR run this:

CREATE TABLE IF NOT EXISTS bmi_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  height_cm DECIMAL(5,2) NOT NULL,
  weight_kg DECIMAL(5,2) NOT NULL,
  bmi_value DECIMAL(4,2) NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('Underweight', 'Normal', 'Overweight', 'Obese')),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE bmi_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own records" ON bmi_records
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own records" ON bmi_records
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own records" ON bmi_records
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own records" ON bmi_records
  FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_bmi_records_user_id ON bmi_records(user_id);
CREATE INDEX IF NOT EXISTS idx_bmi_records_created_at ON bmi_records(created_at DESC);
```

## 2. Verify Table Created

In Supabase Table Editor, you should see `bmi_records` with columns:
- `id` (uuid, primary key)
- `user_id` (uuid, foreign key → auth.users)
- `height_cm` (numeric)
- `weight_kg` (numeric)
- `bmi_value` (numeric)
- `category` (text)
- `notes` (text, nullable)
- `created_at` (timestamp)
- `updated_at` (timestamp)

## 3. App Configuration

Your `.env` is already set:
```
USE_MOCK_DATA=false
SUPABASE_URL=https://mmlukuemgazzrgbxwuep.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 4. Run the App

```bash
cd bmi_tracker
flutter run -d chrome --web-port=51266
```

Access at: http://localhost:51266

## 5. API Testing with Postman

### Login
```
POST http://localhost:8000/api/auth/login
```
Note: Authentication is handled by Supabase, not your local server. You should call Supabase directly:

```
POST https://mmlukuemgazzrgbxwuep.supabase.co/auth/v1/token?grant_type=password
Headers:
  apikey: YOUR_SUPABASE_ANON_KEY
  Content-Type: application/json

Body:
{
  "email": "test@example.com",
  "password": "yourpassword"
}
```

### BMI Records (after login, use the access_token)
```
GET https://mmlukuemgazzrgbxwuep.supabase.co/rest/v1/bmi_records
Headers:
  Authorization: Bearer <access_token>
  apikey: YOUR_SUPABASE_ANON_KEY
  Prefer: return=representation
```

## 6. What Changed

- Replaced HTTP-based `BmiService` with `SupabaseBmiService`
- Removed dependency on `http://localhost:8000/api` backend server
- BMI data now stored directly in Supabase
- Row Level Security ensures users only access their own records

## Troubleshooting

**Error: "bmi_records does not exist"**
→ Run the SQL migration in Supabase SQL Editor

**Error: "Row Level Security policy violation"**
→ Ensure you're authenticated and sending the Bearer token

**Permission denied on bmi_records**
→ Check Supabase Table → Authentication → Policies are enabled
