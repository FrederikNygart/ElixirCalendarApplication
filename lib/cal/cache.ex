defmodule Cal.Cache do
    use GenServer

    def start_link do
        IO.puts "Starting cal cache.."

        GenServer.start_link(__MODULE__, nil, name: :cal_cache)
    end

    def server_process(cal_model_name) do
        GenServer.call(:cal_cache, {:server_process, cal_model_name})
    end

    def init(_) do
        {:ok, Map.new}
    end

    def handle_call({:server_process, cal_model_name}, _, cal_servers) do
        case Map.fetch(cal_servers, cal_model_name) do
            {:ok, cal_server} ->
                 {:reply, cal_server, cal_servers}

            :error ->
                {:ok, new_server} = Cal.Server.start_link(cal_model_name)

                {
                    :reply,
                    new_server,
                    Map.put(cal_servers, cal_model_name, new_server)
                }
        end
    end

end