defmodule Cal.Database do
    @pool_size 3

    def start_link(db_folder) do
        Cal.PoolSupervisor.start_link(db_folder, @pool_size)
    end

    def choose_worker(key) do
        :erlang.phash2(key, @pool_size) + 1
    end

    def store(key, data) do
        key
        |> choose_worker
        |> Cal.DatabaseWorker.store(key, data)
    end

    def get(key) do
        key
        |> choose_worker
        |> Cal.DatabaseWorker.get(key)
    end
end