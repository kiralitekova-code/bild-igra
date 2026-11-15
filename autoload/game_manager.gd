extends Node

var score: int = 0

func reset_score():
    score = 0

func add_score(amount: int):
    score += amount

func get_score() -> int:
    return score
