-- Create bmi_records table
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

-- Enable Row Level Security
ALTER TABLE bmi_records ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own records
CREATE POLICY "Users can view own records" ON bmi_records
  FOR SELECT USING (auth.uid() = user_id);

-- Policy: Users can insert their own records
CREATE POLICY "Users can insert own records" ON bmi_records
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own records
CREATE POLICY "Users can update own records" ON bmi_records
  FOR UPDATE USING (auth.uid() = user_id);

-- Policy: Users can delete their own records
CREATE POLICY "Users can delete own records" ON bmi_records
  FOR DELETE USING (auth.uid() = user_id);

-- Create index for faster queries by user_id
CREATE INDEX IF NOT EXISTS idx_bmi_records_user_id ON bmi_records(user_id);

-- Create index for sorting by created_at
CREATE INDEX IF NOT EXISTS idx_bmi_records_created_at ON bmi_records(created_at DESC);
