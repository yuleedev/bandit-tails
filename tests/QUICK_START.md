# Integration Tests - Quick Start Guide

## TL;DR

```bash
# Run all tests
./tests/run_tests.sh
```

## What Gets Tested

✅ Round timer doesn't desync between players
✅ Loot can't be picked up twice
✅ Keys increment correctly
✅ Door animations sync to all players
✅ Connection failures show error messages
✅ Round wins and ties are calculated correctly

## Individual Tests

```bash
# Round timer synchronization
godot --headless --path . tests/integration/test_round_timer_sync.gd

# Loot pickup mechanics
godot --headless --path . tests/integration/test_loot_pickup.gd

# Key collection
godot --headless --path . tests/integration/test_key_collection.gd

# Door opening and animation sync
godot --headless --path . tests/integration/test_door_opening.gd

# Connection failure handling
godot --headless --path . tests/integration/test_connection_failure.gd

# Round wins and ties
godot --headless --path . tests/integration/test_round_wins.gd
```

## Expected Output

```
==========================================
Mole Heist - Integration Test Suite
==========================================

Using Godot: /Applications/Godot.app/Contents/MacOS/Godot

Running: test_round_timer_sync
----------------------------------------
✓ PASSED

Running: test_loot_pickup
----------------------------------------
✓ PASSED

[... more tests ...]

==========================================
Test Summary
==========================================
Total Tests: 6
Passed: 6
Failed: 0

All tests passed! ✅
```

## Visual Testing (Godot Editor)

1. Open project in Godot
2. Open `tests/test_template.tscn`
3. Attach a test script to the TestRunner node
4. Press F6 to run
5. Check Output console

## Troubleshooting

**"Godot executable not found"**
```bash
# Install Godot 4.x or add to PATH
export PATH="$PATH:/Applications/Godot.app/Contents/MacOS"
```

**Tests fail**
- Check that all fixes from BUGFIXES.md are applied
- Verify you're on the latest commit
- Check console output for specific error

## CI/CD Integration

```yaml
# GitHub Actions example
- name: Run Tests
  run: ./tests/run_tests.sh
```

Exit code: 0 = all pass, 1 = some fail

## More Info

- Full documentation: `tests/README.md`
- Test summary: `tests/TEST_SUMMARY.md`
- Bug fixes: `BUGFIXES.md`
