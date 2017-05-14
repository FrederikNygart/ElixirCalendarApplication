defmodule Cal.Model do
  defstruct auto_id: 1, entries: Map.new

    def new do
        %Cal.Model{}
    end

    def new(entries \\ []) do
        Enum.reduce(
        entries,
        %Cal.Model{},
        &add_entry(&2, &1)
        )
    end

    def add_entry(
        %Cal.Model{entries: entries, auto_id: auto_id} = cal_Model,
        entry
    ) do
        entry = Map.put(entry, :id, auto_id)
        new_entries = Map.put(entries, auto_id, entry)

        %Cal.Model{cal_Model |
        entries: new_entries,
        auto_id: auto_id + 1
        }
    end

    def delete_entry(%Cal.Model{entries: entries} = cal_Model, entry_id) do
        case entries[entry_id] do
        nil -> cal_Model

        entry_to_delete ->
            new_entries = entries
            |> Map.delete(entry_to_delete.id)
            %Cal.Model{cal_Model | entries: new_entries}
        end
    end

    def update_entry(cal_Model, %{} = new_entry) do
        update_entry(cal_Model, new_entry.id, fn(_) -> new_entry end)
    end

    def update_entry(
        %Cal.Model{entries: entries} = cal_Model,
        entry_id,
        update_fun
    ) do
        case entries[entry_id] do
        nil -> cal_Model

        old_entry ->
            old_entry_id = old_entry.id
            new_entry = %{id: ^old_entry_id} = update_fun.(old_entry)
            new_entries = Map.put(
                                entries,
                                new_entry.id,
                                new_entry
                                )
            %Cal.Model{cal_Model | entries: new_entries}
        end
    end

    def entries(%Cal.Model{entries: entries}, date) do
        entries
        |> Stream.filter(fn({_, entry}) ->
            entry.date == date
        end)
        |> Enum.map(fn({_, entry}) ->
            entry
        end)
    end
end