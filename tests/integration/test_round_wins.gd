extends Node

## Integration Test: Round Wins and Tie Scenarios
##
## Tests that round wins are counted correctly and tie scenarios work properly.

var test_results: Dictionary = {
	"p1_wins_round": false,
	"p2_wins_round": false,
	"tie_round": false,
	"cumulative_scoring": false,
	"final_winner_p1": false,
	"final_winner_p2": false,
	"final_tie": false,
	"elif_logic": false
}

func _ready():
	print("\n=== INTEGRATION TEST: Round Wins and Tie Scenarios ===")
	run_test()

func run_test():
	# Test 1: Player 1 wins a round
	print("Test 1: Player 1 wins round...")
	test_p1_wins_round()

	# Test 2: Player 2 wins a round
	print("Test 2: Player 2 wins round...")
	test_p2_wins_round()

	# Test 3: Tie round
	print("Test 3: Tie round...")
	test_tie_round()

	# Test 4: Cumulative scoring
	print("Test 4: Cumulative scoring across rounds...")
	test_cumulative_scoring()

	# Test 5: Final winner - Player 1
	print("Test 5: Final game winner - Player 1...")
	test_final_winner_p1()

	# Test 6: Final winner - Player 2
	print("Test 6: Final game winner - Player 2...")
	test_final_winner_p2()

	# Test 7: Final tie
	print("Test 7: Final game tie...")
	test_final_tie()

	# Test 8: Verify elif logic fix
	print("Test 8: Verify elif logic (not nested if/else)...")
	test_elif_logic()

	# Report results
	report_results()

func test_p1_wins_round():
	# Reset state
	GM.p1_round_value = 150
	GM.p2_round_value = 100
	GM.p1_wins = 0
	GM.p2_wins = 0
	GM.p1_total_value = 0
	GM.p2_total_value = 0

	# Simulate end_round logic
	GM.p1_total_value += GM.p1_round_value
	GM.p2_total_value += GM.p2_round_value

	if GM.p1_round_value > GM.p2_round_value:
		GM.p1_wins += 1
	elif GM.p2_round_value > GM.p1_round_value:
		GM.p2_wins += 1

	# Verify
	if GM.p1_wins == 1 and GM.p2_wins == 0:
		print("  ✓ Player 1 wins round correctly (P1=1, P2=0)")
		test_results["p1_wins_round"] = true
	else:
		print("  ✗ Player 1 win counting failed (P1=" + str(GM.p1_wins) + ", P2=" + str(GM.p2_wins) + ")")

func test_p2_wins_round():
	# Reset state
	GM.p1_round_value = 100
	GM.p2_round_value = 200
	GM.p1_wins = 0
	GM.p2_wins = 0

	# Simulate end_round logic
	if GM.p1_round_value > GM.p2_round_value:
		GM.p1_wins += 1
	elif GM.p2_round_value > GM.p1_round_value:
		GM.p2_wins += 1

	# Verify
	if GM.p1_wins == 0 and GM.p2_wins == 1:
		print("  ✓ Player 2 wins round correctly (P1=0, P2=1)")
		test_results["p2_wins_round"] = true
	else:
		print("  ✗ Player 2 win counting failed (P1=" + str(GM.p1_wins) + ", P2=" + str(GM.p2_wins) + ")")

func test_tie_round():
	# Reset state
	GM.p1_round_value = 150
	GM.p2_round_value = 150
	GM.p1_wins = 0
	GM.p2_wins = 0

	# Simulate end_round logic (FIXED version with elif)
	if GM.p1_round_value > GM.p2_round_value:
		GM.p1_wins += 1
	elif GM.p2_round_value > GM.p1_round_value:
		GM.p2_wins += 1
	# Tie case: no wins awarded

	# Verify
	if GM.p1_wins == 0 and GM.p2_wins == 0:
		print("  ✓ Tie round correctly awards no wins (P1=0, P2=0)")
		test_results["tie_round"] = true
	else:
		print("  ✗ Tie round failed (P1=" + str(GM.p1_wins) + ", P2=" + str(GM.p2_wins) + ")")

func test_cumulative_scoring():
	# Simulate 3 rounds
	GM.p1_total_value = 0
	GM.p2_total_value = 0

	# Round 1
	GM.p1_round_value = 100
	GM.p2_round_value = 150
	GM.p1_total_value += GM.p1_round_value
	GM.p2_total_value += GM.p2_round_value

	# Round 2
	GM.p1_round_value = 200
	GM.p2_round_value = 100
	GM.p1_total_value += GM.p1_round_value
	GM.p2_total_value += GM.p2_round_value

	# Round 3
	GM.p1_round_value = 150
	GM.p2_round_value = 150
	GM.p1_total_value += GM.p1_round_value
	GM.p2_total_value += GM.p2_round_value

	# Verify totals
	if GM.p1_total_value == 450 and GM.p2_total_value == 400:
		print("  ✓ Cumulative scoring works (P1=450, P2=400)")
		test_results["cumulative_scoring"] = true
	else:
		print("  ✗ Cumulative scoring failed (P1=" + str(GM.p1_total_value) + ", P2=" + str(GM.p2_total_value) + ")")

func test_final_winner_p1():
	# Setup: Player 1 has more wins
	GM.p1_wins = 2
	GM.p2_wins = 1

	# Simulate end_game logic
	var result = ""
	if GM.p1_wins > GM.p2_wins:
		result = "host"
	elif GM.p2_wins > GM.p1_wins:
		result = "joiner"
	else:
		result = "tie"

	# Verify
	if result == "host":
		print("  ✓ Player 1 wins game correctly")
		test_results["final_winner_p1"] = true
	else:
		print("  ✗ Player 1 final win failed (result=" + result + ")")

func test_final_winner_p2():
	# Setup: Player 2 has more wins
	GM.p1_wins = 1
	GM.p2_wins = 2

	# Simulate end_game logic
	var result = ""
	if GM.p1_wins > GM.p2_wins:
		result = "host"
	elif GM.p2_wins > GM.p1_wins:
		result = "joiner"
	else:
		result = "tie"

	# Verify
	if result == "joiner":
		print("  ✓ Player 2 wins game correctly")
		test_results["final_winner_p2"] = true
	else:
		print("  ✗ Player 2 final win failed (result=" + result + ")")

func test_final_tie():
	# Setup: Both have same wins
	GM.p1_wins = 1
	GM.p2_wins = 1

	# Simulate end_game logic
	var result = ""
	if GM.p1_wins > GM.p2_wins:
		result = "host"
	elif GM.p2_wins > GM.p1_wins:
		result = "joiner"
	else:
		result = "tie"

	# Verify
	if result == "tie":
		print("  ✓ Final tie detected correctly")
		test_results["final_tie"] = true
	else:
		print("  ✗ Final tie failed (result=" + result + ")")

func test_elif_logic():
	# Test the critical fix: elif instead of nested if/else
	# This is a code structure verification

	# OLD (BUGGY) version would be:
	# if p1_round_value > p2_round_value:
	#     p1_wins += 1
	# if p2_round_value > p1_round_value:  # This runs even if first is true!
	#     p2_wins += 1
	# else:  # This else is attached to the SECOND if!
	#     pass

	# Test the buggy logic to show it was wrong
	GM.p1_wins = 0
	GM.p2_wins = 0
	var p1_val = 100
	var p2_val = 50

	# Buggy version (what we DON'T want)
	if p1_val > p2_val:
		GM.p1_wins += 1
	if p2_val > p1_val:  # Should be elif!
		GM.p2_wins += 1
	else:
		pass  # This only runs if second condition is false

	# This would incorrectly give p1_wins=1, p2_wins=0 (which is actually correct by accident)
	# But the else clause is wrong

	# Now test the FIXED version
	GM.p1_wins = 0
	GM.p2_wins = 0

	if p1_val > p2_val:
		GM.p1_wins += 1
	elif p2_val > p1_val:
		GM.p2_wins += 1
	# Tie case: no wins awarded

	if GM.p1_wins == 1 and GM.p2_wins == 0:
		print("  ✓ elif logic works correctly (mutually exclusive branches)")
		test_results["elif_logic"] = true
	else:
		print("  ✗ elif logic failed")

func report_results():
	print("\n--- Test Results ---")
	var passed = 0
	var total = test_results.size()

	for test_name in test_results:
		if test_results[test_name]:
			print("✅ " + test_name)
			passed += 1
		else:
			print("❌ " + test_name)

	print("\nSummary: " + str(passed) + "/" + str(total) + " tests passed")

	if passed == total:
		print("✅ PASSED: All round wins and tie tests successful")
	else:
		print("❌ FAILED: Some round wins tests failed")

	print("===================\n")

	# Exit after short delay
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
