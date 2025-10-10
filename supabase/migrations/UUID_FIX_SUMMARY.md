# UUID Type Casting Fixes - Summary

## Error Encountered
```
ERROR: 42883: operator does not exist: uuid = text
HINT: No operator matches the given name and argument types. You might need to add explicit type casts.
```

## Root Cause
PostgreSQL cannot directly compare UUID and TEXT types without explicit casting. The RLS policies had several locations where this comparison was attempted.

## Fixes Applied to `20241010_add_advanced_features_rls.sql`

### Fix 1: State ID Comparisons (Lines 49, 115)
**Issue:** Comparing UUID column `projects.state_id` with TEXT value from JSONB `auth.users.raw_user_meta_data->>'state_id'`

**Before:**
```sql
JOIN projects ON projects.state_id = auth.users.raw_user_meta_data->>'state_id'
```

**After:**
```sql
JOIN projects ON projects.state_id = (auth.users.raw_user_meta_data->>'state_id')::uuid
```

**Applied in Policies:**
- `state_view_flags` (line 49)
- `state_view_milestones` (line 115)

### Fix 2: Agency ID Direct Comparison (Lines 71, 84)
**Issue:** Unnecessary subquery and text casting for UUID comparison

**Before:**
```sql
agency_id IN (
    SELECT id FROM agencies
    WHERE agencies.id::text = auth.uid()::text
)
```

**After:**
```sql
agency_id = auth.uid()
```

**Applied in Policies:**
- `agency_view_flags` (line 71)
- `agency_manage_milestones` (line 84)

### Fix 3: JSONB Array UUID Extraction (Lines 215-219, 253-257, 282-286)
**Issue:** Comparing auth.uid() UUID with TEXT extracted from JSONB array

**Before:**
```sql
auth.uid()::text = ANY(
    SELECT jsonb_array_elements_text(workflow->'signer_ids')
)
```

**After:**
```sql
EXISTS (
    SELECT 1
    FROM jsonb_array_elements_text(workflow->'signer_ids') AS signer_id
    WHERE signer_id::uuid = auth.uid()
)
```

**Applied in Policies:**
- `view_assigned_documents` (lines 215-219)
- `view_document_signatures` (lines 253-257)
- `view_document_audit_trail` (lines 282-286)

### Fix 4: Helper Function Type Safety (Lines 312-328)
**Issue:** Function compared UUID parameter with TEXT array

**Before:**
```sql
CREATE OR REPLACE FUNCTION can_sign_document(document_id UUID, user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    doc_workflow JSONB;
    signer_ids TEXT[];
BEGIN
    SELECT workflow INTO doc_workflow
    FROM esign_documents
    WHERE id = document_id;
    
    SELECT ARRAY(SELECT jsonb_array_elements_text(doc_workflow->'signer_ids'))
    INTO signer_ids;
    
    RETURN user_id::text = ANY(signer_ids);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**After:**
```sql
CREATE OR REPLACE FUNCTION can_sign_document(document_id UUID, user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM esign_documents,
        jsonb_array_elements_text(workflow->'signer_ids') AS signer_id
        WHERE esign_documents.id = document_id
        AND signer_id::uuid = user_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Type Casting Rules Applied

1. **UUID to UUID**: Direct comparison without casting
   ```sql
   uuid_column = auth.uid()
   ```

2. **TEXT to UUID**: Explicit casting required
   ```sql
   (jsonb_value->>'key')::uuid = uuid_column
   ```

3. **JSONB Array Elements**: Extract as TEXT, then cast to UUID
   ```sql
   jsonb_array_elements_text(jsonb_column) AS text_value
   WHERE text_value::uuid = uuid_column
   ```

## Testing Recommendations

After applying these fixes, verify:

1. **Run the migration script** in Supabase SQL Editor
2. **Check for errors** - script should execute without UUID comparison errors
3. **Test RLS policies** with different user roles:
   - Centre users can see all data
   - State users see only their state's data
   - Agency users see only their agency's data
   - Overwatch users can see all flagged items

4. **Verify user metadata structure**:
   ```json
   {
     "role": "state",
     "state_id": "uuid-here"  // Store as string, cast in queries
   }
   ```

## Performance Considerations

- Direct UUID comparisons are more efficient than text casting
- EXISTS with JSONB array traversal is more efficient than ANY with subqueries
- Simplified function logic reduces overhead

## Conclusion

All UUID type mismatches have been resolved with explicit type casts. The script is now compatible with PostgreSQL's strict type system and should execute without errors.