import { useEffect, useState } from 'react';
import './App.css';
import { getEntries } from './api/entries/get-entries';
import { postEntry } from './api/entries/post-entries';
import { EntryResponse, EntryRequest } from './api/entries/types/entry';

function App() {
  const [username, setUsername] = useState('');
  const [newEntry, setNewEntry] = useState('');
  const [isEntriesLoading, setIsEntriesLoading] = useState(false);
  const [entryList, setEntryList] = useState<EntryResponse[]>([]);


  async function getDiaryEntries() {
    setIsEntriesLoading(true);
    getEntries(username)
      .then((res) => {
        setEntryList(res.data);
      })
      .catch((e) => {
        console.log(e);
      })
      .finally(() => {
        setIsEntriesLoading(false);
      });
  }

  async function addNewEntry() {
    const payload: EntryRequest = {
      username,
      value: newEntry,
    };
    postEntry(payload)
      .then(() => {
        getDiaryEntries();
      })
      .catch((e) => {
        console.log(e);
      });
  }

  return (
    <div className="App">
      <div className="App-header">
        <input onChange={e => {setUsername(e.target.value)}}/>
        <button onClick={getDiaryEntries}>Get Diary Entries</button>
        <br/>

        {entryList.map((entry) => {
          return (
            <div key={entry.id}>
              {entry.value}
            </div>
          );
        })}

        <br/>

        <input onChange={e => {setNewEntry(e.target.value)}}/>
        <button onClick={addNewEntry}>Add New Entry</button>
      </div>
    </div>
  );
}

export default App;
