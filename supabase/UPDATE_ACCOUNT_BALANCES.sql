-- ============================================
-- ACCOUNT BALANCE UPDATE SCRIPT
-- ============================================
-- This script updates the training and personal account balances
-- to the specified final values

-- ============================================
-- TRAINING ACCOUNT UPDATE
-- ============================================
-- Target: Balance = 2556.61, Total earned = 1456.61 only

UPDATE public.users
SET 
    balance = 2556.61,
    total_earned = 1456.61,
    updated_at = NOW()
WHERE account_type = 'training';

-- Verify training account update
SELECT 
    'Training Account After Update' as account_type,
    email,
    display_name,
    balance,
    total_earned,
    account_type
FROM public.users
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

-- Verify personal account update
SELECT 
    'Personal Account After Update' as account_type,
    email,
    display_name,
    balance,
    total_earned,
    account_type
FROM public.users
WHERE account_type = 'personal';

-- ============================================
-- FINAL VERIFICATION
-- ============================================
SELECT 
    'FINAL VERIFICATION' as status,
    account_type,
    COUNT(*) as count,
    SUM(balance) as total_balance,
    SUM(total_earned) as total_earned
FROM public.users
GROUP BY account_type;

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

RAISE NOTICE '✅ Account balances updated successfully!';
RAISE NOTICE '✅ Training account: Balance = 2556.61, Total earned = 1456.61';
RAISE NOTICE '✅ Personal account: Balance = 51.13 (training commission only)';
