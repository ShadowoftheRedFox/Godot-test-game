## State specialized in UI machine state. Useful to organize behavior between UIs
@abstract class_name MenuMachineState extends StateMachineState

## Called when the machine is ready to setup the menu.
@abstract func setup_menu() -> void
## Called when the machine wants to remove the menu.
@abstract func remove_menu() -> void

func initialiaze() -> void:
    setup_menu()

func destroy() -> void:
    remove_menu()
