require "spec_helper"

describe Anki do
  describe "transfer_900_line" do
    it "1. I see. 			我明白了。" do
      line = "1. I see. 			我明白了。"
      a = Anki.new.transfer_900_line(line)
      expect(["1.", "I see.", "我明白了。"]).to eq(a)
    end
    it "21. How much?   多少钱?" do
      line = "21. How much?   多少钱?"
      a = Anki.new.transfer_900_line(line)
      expect(["21.", "How much?", "多少钱?"]).to eq(a)
    end
    it "41. What's up?          有什么事吗?" do
      line = "41. What's up?          有什么事吗?"
      a = Anki.new.transfer_900_line(line)
      expect(["41.", "What's up?", "有什么事吗?"]).to eq(a)
    end
    it "899. I'm sorry, these 2 books are 3 days overdue.小姐，对不起，这两本书已经过期3天了。" do
      line = "899. I'm sorry, these 2 books are 3 days overdue.小姐，对不起，这两本书已经过期3天了。"
      a = Anki.new.transfer_900_line(line)
      expect(["899.", "I'm sorry, these 2 books are 3 days overdue.", "小姐，对不起，这两本书已经过期3天了。"]).to eq(a)
    end
    it "577. I'd like to-repair our differences． 我愿意消除一下我们之间的分歧。" do
      line = "577. I'd like to-repair our differences． 我愿意消除一下我们之间的分歧。"
      a = Anki.new.transfer_900_line(line)
      expect(["577.", "I'd like to-repair our differences.", "我愿意消除一下我们之间的分歧。"]).to eq(a)
    end


  end
end
