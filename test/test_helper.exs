# Application.load(:my_app) #(1)

# for app <- Application.spec(:my_app,:applications) do #(2)
#   Application.ensure_all_started(app)
# end

Application.ensure_all_started(:gproc)
ExUnit.start()
