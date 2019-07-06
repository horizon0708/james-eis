
- PubSub broadcast socket?? ... abstraction?

- game command validation
    - in A's turn ignore all commands from other players except system...
        - need: issuer
        - version? timestamp?
    - state based - in pause, ignore all except...

- if validation is good, then we can test by literally attepmting to pass all valid actions until game end

- before state change

- need a hook to react to state change (?)
    - prev state, curr state
    - 

# Timer

https://medium.com/@leovergara.dark/timer-with-elixir-1115095cc2cb


### unhandled doens't error

  def handle_info(_, state) do
      {:ok, state}
  end