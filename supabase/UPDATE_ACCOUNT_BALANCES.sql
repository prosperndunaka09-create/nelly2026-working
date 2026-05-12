-- ============================================
-- ACCOUNT BALANCE UPDATE SCRIPT
-- ============================================
-- This script updates the training and personal account balances
-- to the specified final values

-- ============================================
-- TRAINING ACCOUNT UPDATE
-- ============================================
-- Target: Balance = 2505.48 (2556.61 - 51.13 commission), Total earned = 1456.61 only

UPDATE public.users
SET 
    balance = 2505.48,
    total_earned = 1456.61,
    updated_at = NOW()
WHERE account_type = 'training';

-- ============================================
-- PERSONAL ACCOUNT UPDATE
-- ============================================
-- Target: Remove previous 4.06 balance, Reset personal balance to 0, 
-- Apply only training commission 51.13, Final personal balance = 51.13

-- First, reset personal account balance to 0
UPDATE public.users
SET 
    balance = 0.00,
    total_earned = 0.00,
    updated_at = NOW()
WHERE account_type = 'personal';

-- Then apply training commission of 51.13
UPDATE public.users
SET 
    balance = balance + 51.13,
    total_earned = total_earned + 51.13,
    updated_at = NOW()
WHERE account_type = 'personal';

-- ============================================
-- LOG THE BALANCE UPDATE
-- ============================================
INSERT INTO public.transactions (user_id, type, amount, description, status)
SELECT 
    id,
    'balance_adjustment',
    balance,
    'Final balance adjustment - Training: 2556.61, Personal: 51.13',
    'completed'
FROM public.users
WHERE account_type IN ('training', 'personal');
