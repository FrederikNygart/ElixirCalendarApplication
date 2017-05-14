defmodule Cal.Server do
    use GenServer

    def start_link(list_name) do
        GenServer.start_link(Cal.Server, list_name)
    end

    def init(list_name) do
        {:ok, {list_name, Cal.Database.get(list_name) || Cal.Model.new}}
    end

    def add_entry(pid, entry) do
        GenServer.cast(pid, {:add, entry})
    end

    def update_entry(pid, entry) do
        GenServer.cast(pid, {:update, entry})
    end

    def delete_entry(pid, entry_id) do
        GenServer.cast(pid, {:delete, entry_id})
    end

    def entries(pid, date) do
        GenServer.call(pid, {:get, date})
    end

    def handle_cast({:add, entry}, {name, cal}) do
        new_state = Cal.Model.add_entry(cal, entry)
        Cal.Database.store(name, new_state)
        {:noreply, {name, new_state}}
    end

    def handle_cast({:update, entry}, state) do
        {:noreply, Cal.Model.update_entry(state, entry)}
    end

    def handle_cast({:delete, entry_id}, state) do
        {:noreply, Cal.Model.delete_entry(state, entry_id)}
    end

    def handle_call({:get, date}, _from, {name, cal}) do
        {:reply, Cal.Model.entries(cal, date), {name, cal}}
    end
end