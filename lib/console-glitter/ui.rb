# typed: strict
require 'console-glitter'
require 'console-glitter/ansi'
require 'readline'
require 'io/console'

module ConsoleGlitter
  module UI extend self
    extend ANSI
    # Public: Prompt user for input, allowing for a default answer and a list
    # of valid responses to be provided.
    #
    # question - Query to be presented to the user.
    # options  - Hash containing arguments defining acceptable responses.
    #            (default: {}):
    #            :default_answer - String containing the default answer.  If
    #                              this is nil, a non-empty answer MUST be
    #                              given.
    #            :allow_empty    - Whether or not to allow empty responses.
    #                              Unless explicitly allowed, empty answers
    #                              will be rejected.
    #            :valid_answers  - An Array containing all valid responses.  If
    #                              this is empty, any answer will be accepted
    #                              (unless empty answers are disallowed as
    #                              specified above).  Valid responses may be
    #                              any class with a match method such as
    #                              Strings or Regexps.
    # wordlist - Array of words to be used for input auto-completion.
    #            (default: [])
    # block    - Lambda which will override the default autocompletion lambda
    #            as defined in autocomplete_lambda if present.  (default: nil)
    #
    # Returns a String containing the answer provided by the user.
    def prompt(question, options = {}, wordlist = [], &block)
      default = options[:default_answer].to_s
      allow_empty = options[:allow_empty]
      valid = regexify_answers(Array(options[:valid_answers]))

      default_display = " [#{default.strip}]" unless default.empty?
      question = "#{question.strip}#{default_display}> "

      answer = { answer: nil }
      while answer[:answer].nil?
        answer[:answer] = user_prompt(question, wordlist, &block)
        answer[:answer] = default if answer.empty?

        if answer[:answer].empty?
          answer[:answer] = nil unless allow_empty
        elsif valid.any?
          unless valid.map { |valid| answer[:answer].match(valid) }.any?
            answer[:answer] = nil
          end
        end
      end

      answer[:answer]
    end

    # Public: Wrap Console#prompt but accept only a Y/N response.
    #
    # question - String containing the question to present to the user.
    # args     - Hash containing arguments to control acceptable responses.
    #            (default: {}):
    #            :default_answer - String containing the default answer.
    #
    # Returns true or false corresponding to Y or N answer respectively.
    def prompt_yn(question, args = {})
      args[:valid_answers] = [/^[yn]/i]
      /^n/i.match(prompt(question, args)).nil?
    end

    # Public: Wrap Console#prompt, disabling local echo of user input.
    #
    # question - Query to be presented to the user.
    # options  - Hash containing arguments defining acceptable responses.
    #            (default: {}):
    #            :default_answer - String containing the default answer.  If
    #                              this is nil, a non-empty answer MUST be
    #                              given.
    #            :allow_empty    - Whether or not to allow empty responses.
    #                              Unless explicitly allowed, empty answers
    #                              will be rejected.
    #            :valid_answers  - An Array containing all valid responses.  If
    #                              this is empty, any answer will be accepted
    #                              (unless empty answers are disallowed as
    #                              specified above).  Valid responses may be
    #                              any class with a match method such as
    #                              Strings or Regexps.
    #
    # Returns a String containing the answer provided by the user.
    def secure_prompt(question, args = {})
      IO.console.echo = false
      prompt(question, args)
    ensure
      IO.console.echo = true
      puts
    end

    # Public: Wrap Console#prompt, specifically targeting filesystem paths.
    #
    # question - Query to be presented to the user.
    # options  - Hash containing arguments defining acceptable responses.
    #            (default: {}):
    #            :default_answer - String containing the default answer.  If
    #                              this is nil, a non-empty answer MUST be
    #                              given.
    #            :allow_empty    - Whether or not to allow empty responses.
    #                              Unless explicitly allowed, empty answers
    #                              will be rejected.
    #            :valid_answers  - An Array containing all valid responses.  If
    #                              this is empty, any answer will be accepted
    #                              (unless empty answers are disallowed as
    #                              specified above).  Valid responses may be
    #                              any class with a match method such as
    #                              Strings or Regexps.
    #
    # Returns a String containing the answer provided by the user.
    def prompt_filesystem(question, args = {})
      fs_lambda = lambda { |d| Dir[d + '*'].grep(/^#{Regexp.escape(d)}/) }
      old_append = Readline.completion_append_character

      Readline.completion_append_character = ''
      response = prompt(question, args, [], &fs_lambda)
      Readline.completion_append_character = old_append

      response
    end

    # Public: Render a "spinner" on the command line and yield to a block,
    # reporting success if nothing is raised, or else reporting failure.
    #
    # message - Message to be displayed describing the task being evaluated.
    # block   - Block to be yielded to determine pass or fail.
    #
    # Returns the result of the yielded block if successful.
    # Raises whatever is raised inside the yielded block.
    def spinner(message, &block)
      success = { success: nil }
      result = nil

      pre = "\r#{bold}#{white} [#{reset}"
      post = "#{bold}#{white}] #{reset}#{message}"
      pre_ok = "\r#{bold}#{white} [#{green} ok "
      pre_fail = "\r#{bold}#{white} [#{red}fail"

      thread = Thread.new do
        step = 0
        spin = ["    ", ".   ", "..  ", "... ", "....", " ...", "  ..", "   ."]
        while success[:success].nil?
          print "#{pre}#{spin[step % 8]}#{post}"
          step += 1
          sleep 0.5
        end

        if success[:success]
          print "#{pre_ok}#{post}\n"
        else
          print "#{pre_fail}#{post}\n"
        end
      end

      begin
        result = yield
        success[:success] = true
        thread.join
        return result
      rescue
        success[:success] = false
        thread.join
        raise
      end
    end

    # Public: Generate a formatted, printable table.
    #
    # rows   - An Array containing Hashes which contain desired options to
    #          display. (e.g. [{"col1" => "a", "col2" => "b"}])
    # labels - Hash containing key-value pairs to label each key in options.
    #          (default: nil)
    #
    # Returns a String containing the grid.
    # Raises ArgumentError if anything but an Array is passed as rows.
    def build_grid(rows, labels = rows.first.keys.reduce({}) { |c,e| c.merge({e => e}) })
      keys = labels.keys

      max_width = labels.reduce({}) do |c,e|
        c.merge({e[0]=> ([labels] + rows).map { |r| r[e[0]].to_s.length }.max})
      end

      grid_rule = max_width.reduce('+') do |c,e|
        c + ('-' * (e[1] + 2)) + '+'
      end
      grid_rule << "\n"

      grid = grid_rule.dup
      grid << keys.reduce('|') do |c,e|
        c + " #{bold}% #{max_width[e]}s#{reset} |" % labels[e]
      end
      grid << "\n#{grid_rule}"

      step = rows.map do |r|
        "|" + keys.map { |k| sprintf(" % #{max_width[k]}s |", r[k.to_s]) }.join
      end
      grid + step.join("\n") + "\n" + grid_rule
    end

    private

    # Internal: Promp user for input via Readline, handling automatic setting
    # and restoring of Readline's autocompletion proc, avoiding trampling over
    # other uses.
    #
    # question - String containing a question to be displayed to the user.
    # wordlist - Array containing Strings which are considered valid answers
    #            for autocompletion.
    # block    - Lambda which will override the default autocompletion lambda
    #            as defined in autocomplete_lambda if present.  (default: nil)
    #
    # Returns a String.
    def user_prompt(question, wordlist, &block)
      block = autocomplete_lambda(wordlist) if block.nil?
      old_completion_proc = Readline.completion_proc

      Readline.completion_proc = block
      response = Readline.readline(question)
      Readline.completion_proc = old_completion_proc

      response.to_s
    end

    # Internal: Generate a lambda which retuns an array of autocompletion
    # candidates.
    #
    # wordlist - Array containing Strings which are considered valid answers
    #            for autocompletion.
    #
    # Returns a lambda which returns an Array.
    def autocomplete_lambda(wordlist)
      wl = wordlist.to_a
      lambda { |s| wl.grep(/^#{Regexp.escape(s)}/) }
    end

    # Internal: Generate Regexps for any String in an array to be used in order
    # to match against user input.  Strings are expected to indicate exact
    # matches desired.
    #
    # valid_answers - Array containing Objects against which user input may be
    #                 matched.
    #
    # Returns an Array of Regexps.
    def regexify_answers(valid_answers)
      valid_answers
        .to_a
        .map do |answer|
        unless answer.is_a?(Regexp)
          Regexp.new("^#{Regexp.escape(answer.to_s)}$")
        else
          answer
        end
      end
    end
  end
end
