require "cksh_commander"

module Test
  class Command < CKSHCommander::Command
    set token: "gIkuvaNzQIHg97ATvDxqgjtO"
    set error_message: "Bad news..."

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

    def test4(text1, optional = nil)
      content = optional || text1
      set_response_text("Test 4: #{content}")
    end

    def testprivate
      authorize(["AUTHORIZED"])
      set_response_text("You are authorized!")
    end

    def testerror
      nomethod
    end

    def testerrordebugging
      debug!
      nomethod
    end

    def ___(text)
      set_response_text("___: #{text}")
    end
  end
end
