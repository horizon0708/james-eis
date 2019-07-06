defmodule StatefulListTest do
  use ExUnit.Case

  test "next" do
    int_list = ["a", "b", "c", "d"]
    test_list = %StatefulList{internal_list: int_list}

    assert StatefulList.current(test_list) == "a"

    test_list = StatefulList.next(test_list)
    assert StatefulList.current(test_list) == "b"

    test_list = StatefulList.next(test_list)
    assert StatefulList.current(test_list) == "c"

    test_list = StatefulList.next(test_list)
    assert StatefulList.current(test_list) == "d"

    #should loop around to "a"
    test_list = StatefulList.next(test_list)
    assert StatefulList.current(test_list) == "a"

    #jump with valid index
    test_list = StatefulList.jump(test_list, 1)
    assert StatefulList.current(test_list) == "b"

    # invalid index, but should go to last element
    test_list = StatefulList.jump(test_list, 10)
    assert StatefulList.current(test_list) == "d"

    test_list = StatefulList.previous(test_list)
    assert StatefulList.current(test_list) == "b"
  end
end
