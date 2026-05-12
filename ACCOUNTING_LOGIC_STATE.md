# Accounting Logic State - Stable Reference

**Branch:** `stable-accounting-fix`  
**Date:** May 13, 2026  
**Commit:** af229b5 - "Fix accounting logic: deduct 2% commission from training balance on transfer"

---

## Current Accounting Logic (VERIFIED WORKING)

### Balance Calculations

**Training Account:**
- Initial balance: 2556.61
- Commission rate: 2% (0.02)
- Commission amount: 51.13
- **Final balance: 2505.48** (2556.61 - 51.13)
- Total earned: 1456.61 (unchanged)

**Personal Account:**
- Commission received: 51.13 (2% of training balance)
- **Final balance: 51.13**
- Total earned: 51.13

**Combined Total:**
- Training (2505.48) + Personal (51.13) = **2556.61**
- No duplication of funds ✓

---

## Key Files & Logic

### 1. Commission Transfer Logic
**File:** `src/services/supabaseService.ts`  
**Function:** `completeTrainingAndTransferBalance()` (lines 804-922)

**Current Logic:**
```typescript
// Calculate 2% commission to transfer to personal account
const commissionAmount = Math.round(trainingBalance * 0.02 * 100) / 100;
const remainingTrainingBalance = Math.round((trainingBalance - commissionAmount) * 100) / 100;

// Update training account - deduct commission
balance: remainingTrainingBalance

// Update personal account - add commission only
balance: currentPersonalBalance + commissionAmount
```

### 2. Database Schema
**Table:** `public.users`
- `balance` - Current account balance
- `total_earned` - Total earnings accumulated
- `account_type` - 'training' or 'personal'
- `training_completed` - Boolean flag

### 3. Transaction Records
**Table:** `public.transactions`
- Training account: Debit transaction (type: 'withdrawal')
- Personal account: Credit transaction (type: 'earning')
- Amount: commissionAmount (51.13)

---

## Critical Rules - DO NOT MODIFY

### Protected Components:
1. **Commission rate** - Fixed at 2% (0.02)
2. **Balance calculation** - Training balance = total - commission
3. **Transfer logic** - Only transfer commission amount, not full balance
4. **Withdrawal logic** - Must respect current balance after commission deduction
5. **Training/personal account transfer** - Must preserve the 2% deduction rule

### Forbidden Changes:
- ❌ Modifying commission rate from 2%
- ❌ Transferring full training balance to personal account
- ❌ Bypassing commission deduction
- ❌ Altering balance calculation formulas
- ❌ Changing transaction record amounts

---

## Regression Test Checklist

### Pre-Deployment Tests:
- [ ] Verify training accounts show balance = 2505.48
- [ ] Verify personal accounts show balance = 51.13
- [ ] Verify combined total = 2556.61 (no duplication)
- [ ] Test commission transfer function in development
- [ ] Verify transaction records show correct amounts
- [ ] Test withdrawal with new balance (training: 2505.48)
- [ ] Test withdrawal with new balance (personal: 51.13)
- [ ] Verify navbar balance displays correctly
- [ ] Verify available balance displays correctly
- [ ] Verify max withdrawal calculation
- [ ] Verify withdraw all button functionality

### Database Verification Query:
```sql
SELECT account_type, COUNT(*), SUM(balance), AVG(balance)
FROM public.users
WHERE account_type IN ('training', 'personal')
GROUP BY account_type;
```

**Expected Results:**
- Training: balance = 2505.48 per account
- Personal: balance = 51.13 per account

---

## Deployment Safety

### Before Any Deployment:
1. Run regression tests from checklist above
2. Verify database state matches expected values
3. Test commission transfer logic in staging/development
4. Review all changes to `supabaseService.ts`
5. Review all changes to balance-related components

### Rollback Plan:
If issues occur after deployment:
1. Revert to branch `stable-accounting-fix`
2. Apply SQL: `supabase/UPDATE_ACCOUNT_BALANCES.sql`
3. Redeploy from stable branch

---

## Future Development Guidelines

### Adding New Features:
1. **Preserve accounting logic** - Any feature must maintain:
   - Training balance = total - commission
   - Personal balance = commission only
   - No fund duplication

2. **Test impact on balances** - Any change affecting balances must:
   - Run regression tests
   - Verify combined total unchanged
   - Test with both account types

3. **Document changes** - Update this file if logic changes

### Example Safe Changes:
- ✅ UI improvements (no balance logic)
- ✅ New task types (preserve commission rate)
- ✅ Admin panel features (read-only on balances)
- ✅ Notification systems (independent of accounting)

### Example Unsafe Changes (Require Approval):
- ⚠️ Modifying commission rate
- ⚠️ Changing transfer logic
- ⚠️ Altering withdrawal calculations
- ⚠️ Adding new balance fields
- ⚠️ Modifying transaction amounts

---

## Contact & Approval

**For any changes to accounting logic:**
- Get explicit user approval before modification
- Document reason for change
- Update this file with new logic
- Run full regression suite

**Current State:** ✅ STABLE & VERIFIED
