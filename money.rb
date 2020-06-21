require "yaml"
require "json"
require "date"

class Money 
  def initialize(goal)
    @goal = goal
    @money_left_to_earn = goal
    @initialization_date = Date.today.strftime
  end

  def update_money(earned_money)
    @money_left_to_earn -= earned_money
    UpdateMoney.new(earned_money)
    puts "Your earned money/spent (#{earned_money}) has been added to overall value"
    how_many_days_left?(earned_money)
  end

  def show_stats
  puts "Initial day: #{@initialization_date}"
    json_array = File.read("money_stats.json").gsub("\"", "").split("\n")
    json_array.map! do |idx|
      [idx.split(",")[0], idx.split(",")[1]]
    end
    json_array.each do |el|
      puts "#{el.last[5..-2]}: #{el.first[8..-1]} zł"
    end
  puts "Goal: #{@goal} zł"
  puts "Money left to achieve this goal: #{@money_left_to_earn} zł"
  end

  private

  def how_many_days_left?(payout)
    puts "With your current payout you'll have to work for approximately #{(@money_left_to_earn/payout) + 1} days left"
  end
end

class UpdateMoney
  def initialize(earned_money)
    open("money_stats.json","a") do |line| 
      line.puts JSON.dump({
      payout: earned_money,
      date: Date.today.strftime
      })
    end
  end
end

def update_existing_progress(object, choice = "")
  puts "1: Input earned money"
  puts "2: See your stats"
  choice = gets.chomp.to_i
  update_existing_progress(object) unless choice == 1 || choice == 2

  if choice == 1 
    puts "How much money have you earned/spent today?"
    money_amount = gets.chomp.to_i 
    update_existing_progress(object, 1) unless money_amount.class == Integer
    object.update_money(money_amount)
    open("money_progress.yaml", "w"){|line| line.puts YAML.dump(object)}

  else
    object.show_stats
  end
end

def money_program(choice = "")
  if choice == ""
    puts "THERE ALREADY EXISTS A FILE WITH YOUR PROGRESS" if File.exists?("money_progress.yaml")
    puts "What would you like to do?"
    puts "1: Set a new goal/reset progress"
    puts "2: Update my current progress"
    choice = gets.chomp.to_i

  end

  money_program unless choice == 1 || choice == 2

  if choice == 1
    puts "How much money would you like to set up as your goal?"
    money_amount = gets.chomp.to_i
    money_program(choice) unless money_amount.class == Integer && money_amount > 0 
    money = Money.new(money_amount) 
    open("money_stats.json", "w+")
    open("money_progress.yaml", "w+"){|line| line.puts YAML.dump(money)}

  elsif choice == 2
    if File.exists?("money_progress.yaml")
      prev_progress = YAML.load File.read("money_progress.yaml")
      update_existing_progress(prev_progress)

    else
      puts "You have to set up your goal first"
      money_program(1)
    end
  end
end
puts "money-organizer initialized"
money_program