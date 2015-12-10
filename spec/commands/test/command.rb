require "cksh_commander"

module Test
  class Command < CKSHCommander::Command
    set token: "gIkuvaNzQIHg97ATvDxqgjtO"

    desc "test0", "Description."
    def test0
      set_response_text("Test 0")
    end

    desc "test1 [TEXT]", "Description."
    def test1(text)
      set_response_text("Test 1: #{text}")
    end

    def test2(text1, text2)
      set_response_text("Test 2: #{text1}#{text2}")
    end

    def test3(text1, text2, text3)
      set_response_text("Test 3: #{text1}#{text2} #{text3}")
    end

    def ___(text)
      set_response_text("___: #{text}")
    end
  end
end
