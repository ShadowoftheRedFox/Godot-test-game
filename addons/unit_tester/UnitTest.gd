## Script having a test function.
@abstract class_name UnitTest

## Initialize the script before launching the test.
func initialize() -> void:
    pass

## Clean the script after launching the test.
func clean() -> void:
    pass

## Run the unit tests.
@abstract func test() -> void
