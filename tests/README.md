# Integration Tests - Mole Heist

This directory contains integration tests for the multiplayer networking fixes documented in `BUGFIXES.md`.

## Overview

These are **integration tests**, not unit tests. They test complete multiplayer scenarios end-to-end, verifying that:
- Round timer synchronization works correctly
- Loot pickup handles simultaneous pickups
- Key collection increments properly for both players
- Door animations sync to all clients
- Connection failures are handled gracefully
- Round wins and ties are calculated correctly

## Test Files

| Test File | Description | Scenarios Tested |
|-----------|-------------|------------------|
| `test_round_timer_sync.gd` | Round timer synchronization | Server triggers round end, clients receive RPC |
| `test_loot_pickup.gd` | Loot pickup mechanics | Simultaneous pickup, value updates, no double-pickup |
| `test_key_collection.gd` | Key collection | P1/P2 key increment, no double-collection, multiple keys |
| `test_door_opening.gd` | Door opening | Animation sync, key consumption, server validation |
| `test_connection_failure.gd` | Connection handling | Error messages, disconnect handling, return to menu |
| `test_round_wins.gd` | Win counting | P1 wins, P2 wins, ties, cumulative scoring |

## Running Tests

### Method 1: Automated Test Runner (Recommended)

```bash
# Run all tests
./tests/run_tests.sh
```

This script:
- Automatically finds your Godot installation
- Runs all integration tests in sequence
- Provides colored output with pass/fail summary
- Returns exit code 0 if all tests pass, 1 if any fail

### Method 2: Manual Godot Command Line

Run individual tests:

```bash
# Example: Run round timer test
godot --headless --path . tests/integration/test_round_timer_sync.gd

# Example: Run loot pickup test
godot --headless --path . tests/integration/test_loot_pickup.gd
```

### Method 3: Godot Editor (Visual)

1. Open the project in Godot Editor
2. Create a new scene
3. Add a Node as root
4. Attach one of the test scripts to it
5. Run the scene (F6)
6. Check the Output console for results

## Test Results Format

Each test outputs:
```
=== INTEGRATION TEST: [Test Name] ===
Test 1: [Description]...
  ✓ [Success message]
Test 2: [Description]...
  ✓ [Success message]

--- Test Results ---
✅ test_name_1
✅ test_name_2
❌ test_name_3

Summary: 2/3 tests passed
✅ PASSED: All tests successful
===================
```

## What These Tests Verify

### 1. Round Timer Sync (`test_round_timer_sync.gd`)
- ✅ Only server triggers `end_round.rpc()` when timer expires
- ✅ Client does NOT call `end_round()` directly
- ✅ Both server and client receive and execute the RPC

**Why this matters:** Prevents desynchronization where one client ends the round early/late due to different frame rates.

### 2. Loot Pickup (`test_loot_pickup.gd`)
- ✅ Two players can pick up different items simultaneously
- ✅ Player 1's round value updates correctly
- ✅ Player 2's round value updates correctly
- ✅ Same item cannot be picked up twice (`is_picked` flag prevents double-pickup)
- ✅ RPC calls use `call_local` for proper synchronization

**Why this matters:** Ensures fair gameplay and prevents item duplication exploits.

### 3. Key Collection (`test_key_collection.gd`)
- ✅ Player 1 key count increments correctly
- ✅ Player 2 key count increments correctly
- ✅ Keys cannot be collected twice
- ✅ Server validates all key pickups
- ✅ Multiple keys can be collected by both players

**Why this matters:** Keys are critical for progression (opening doors), so accurate counting is essential.

### 4. Door Opening (`test_door_opening.gd`)
- ✅ Doors open when player has a key
- ✅ Animation plays on both server and client (via `@rpc("call_local")`)
- ✅ Keys are consumed on door opening
- ✅ Doors don't open without a key
- ✅ Both players can open doors

**Why this matters:** Door animations must sync to prevent confusion about door state.

### 5. Connection Failure (`test_connection_failure.gd`)
- ✅ Connection failure handler is registered
- ✅ Error message is shown to user via `push_error()`
- ✅ Client returns to menu on connection failure
- ✅ Peer disconnection is handled gracefully
- ✅ Informative messages are logged

**Why this matters:** Proper error handling prevents players from getting stuck on failed connections.

### 6. Round Wins (`test_round_wins.gd`)
- ✅ Player 1 wins are counted correctly
- ✅ Player 2 wins are counted correctly
- ✅ Tie rounds award no wins
- ✅ Cumulative scoring works across rounds
- ✅ Final winner determination (P1, P2, or tie)
- ✅ `elif` logic prevents incorrect tie handling

**Why this matters:** The critical `elif` fix ensures ties are handled correctly (was a nested if/else bug).

## Adding New Tests

To add a new integration test:

1. Create `test_your_feature.gd` in `tests/integration/`
2. Extend `Node` and implement:
   ```gdscript
   extends Node

   var test_results: Dictionary = {}

   func _ready():
       print("\n=== INTEGRATION TEST: Your Feature ===")
       run_test()

   func run_test():
       # Your test logic
       pass

   func report_results():
       # Report pass/fail
       pass
   ```
3. Add the test to `TESTS` array in `run_tests.sh`
4. Run `./tests/run_tests.sh` to verify

## Best Practices

### DO:
- Test complete scenarios end-to-end
- Verify both success and failure cases
- Clean up created nodes with `queue_free()`
- Use `await get_tree().process_frame` for async operations
- Print clear success/failure messages
- Reset GM state between tests

### DON'T:
- Create unit tests (test isolated functions)
- Rely on actual network connections (mock multiplayer state)
- Leave nodes in the scene tree after tests
- Test implementation details (test behavior, not code structure)

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Integration Tests
  run: |
    ./tests/run_tests.sh
```

The script exits with code 0 on success, 1 on failure.

## Troubleshooting

### "Godot executable not found"
- Ensure Godot 4.x is installed
- Add Godot to PATH or update `GODOT` variable in `run_tests.sh`

### "Scene/resource not found"
- Ensure you're running tests from the project root
- Check that resource paths use `res://` prefix

### Tests hang or don't exit
- Tests call `get_tree().quit()` after completion
- If hanging, check for infinite loops in test logic

### False negatives
- Some tests mock multiplayer state since we can't spawn actual network peers
- Tests verify code structure and behavior, not live network traffic

## Coverage

These tests cover the 12 critical bugs fixed in `BUGFIXES.md`:

| Bug # | Bug Description | Test Coverage |
|-------|----------------|---------------|
| 1 | Treasure exit typo | ✅ test_loot_pickup.gd |
| 2 | Signal connection error | ✅ test_loot_pickup.gd, test_key_collection.gd |
| 3 | Round win logic | ✅ test_round_wins.gd |
| 4 | Timer desync | ✅ test_round_timer_sync.gd |
| 5 | Double RPC call | ✅ test_loot_pickup.gd |
| 6 | Door animation sync | ✅ test_door_opening.gd |
| 7 | Security risk | ⚠️ Manual verification (removed code) |
| 8 | Server authority | ✅ test_round_timer_sync.gd |
| 9 | Key double-increment | ✅ test_key_collection.gd |
| 10 | Visibility override | ✅ test_loot_pickup.gd |
| 11 | Race condition | ✅ test_round_timer_sync.gd |
| 12 | Connection handling | ✅ test_connection_failure.gd |

**Coverage: 11/12 bugs (91.7%)** - Security fix verified via code review

## Support

For issues with tests, check:
1. Godot version (requires 4.x)
2. Project configuration
3. Console output for detailed error messages
4. Individual test files for specific scenario details
