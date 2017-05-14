defmodule Cal.ProcessRegistry do
    use GenServer
    import Kernel, except: [send: 2]

    def start_link do
        GenServer.start_link(
            __MODULE__,
            nil,
            name: :registry
        )    
    end

    def init(_) do
        {:ok, Map.new}
    end

    def send(key, message) do
        case whereis_name(key) do
            :undefined ->
                {:badarg, {key, message}}
            pid ->
                Kernel.send(pid, message)
                pid
        end
    end

    def register_name(key, pid) do
        GenServer.call(:registry, {:register_name, key, pid})
    end

    def unregister_name(key) do
        GenServer.call(:registry, {:unregister_name, key})
    end

    def whereis_name(key) do
        GenServer.call(:registry, {:whereis_name, key})
    end

    def handle_call({:register_name, key, pid}, _, process_registry) do
        case Map.get(process_registry, key) do
            nil ->
                Process.monitor(pid)
                {:reply, :yes, Map.put(process_registry, key, pid)}
            _ ->
                {:reply, :no, process_registry}
        end
    end

    def handle_call({:unregister_name, key}, _, process_registry) do
        {
            :noreply,
            Map.delete(process_registry, key)
        }
    end

    def handle_call({:whereis_name, key}, _, process_registry) do
        {
            :reply,
            Map.get(process_registry, key, :undefined),
            process_registry
        }
    end

    def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
        {:noreply, deregister_pid(process_registry, pid)}
    end

    def deregister_pid(process_registry, pid) do
        key = process_registry
        |> Enum.find(fn {key, val} -> val == pid end)
        |> elem(0)

        Map.delete(process_registry, key)
    end

end