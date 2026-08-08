# 5x5 Matrix Spawn Pattern

## Use Case
Boss waves spawn zombies in a 5x5 grid formation (25 zombies per wave).

## Implementation
```gdscript
const SPAWN_MATRIX_SIZE = 5
const SQUARE_SPACING = 60.0

func _spawn_matrix():
    var total_zombies = SPAWN_MATRIX_SIZE * SPAWN_MATRIX_SIZE
    for row in range(SPAWN_MATRIX_SIZE):
        for col in range(SPAWN_MATRIX_SIZE):
            var zombie = load("res://scripts/Zombie.gd").new()
            var x = start_x + col * SQUARE_SPACING
            var y = SPAWN_TOP_Y + row * SQUARE_SPACING
            zombie.position = Vector2(x, y)
            add_child(zombie)
```

## Notes
- Zombies spawn from left or right side (alternating)
- Total 25 zombies per matrix
- Spacing is 60 pixels between each zombie
