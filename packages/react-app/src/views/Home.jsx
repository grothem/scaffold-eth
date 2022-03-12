import { useContractReader } from "eth-hooks";
import { ethers } from "ethers";
import React from "react";
import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Button, Input } from "antd";

/**
 * web3 props can be passed from '../App.jsx' into your local view component for use
 * @param {*} yourLocalBalance balance on current network
 * @param {*} readContracts contracts from current chain already pre-loaded using ethers contract module. More here https://docs.ethers.io/v5/api/contract/contract/
 * @returns react component
 **/
function Home({ tx, address, readContracts, writeContracts }) {
  // you can also use hooks locally in your component of choice
  // in this case, let's keep track of 'purpose' variable from our contract
  const myBalance = useContractReader(readContracts, "Notepad", "balanceOf", [address, 1]);

  const [notepad, setNotepad] = useState();
  useEffect(() => {
    const yourNotepad = async () => {
      if (!myBalance) return;
      // assuming only 1 for now
      const tokenURI = await readContracts.Notepad.tokenURI(address, 1);
      console.log(tokenURI);
      if (tokenURI) {
        const decoded = Buffer.from(tokenURI.substring(29), "base64");
        const parsed = JSON.parse(decoded);
        setNotepad(parsed.image);
      }
    };

    yourNotepad();
  }, [myBalance]);

  const [note, setNote] = useState("");

  const onAddNote = async () => {
    await tx(writeContracts.Notepad.addToNote(note));
    setNote("");
  };

  return (
    <div className="flex flex-col">
      <Input style={{ width: "500px" }} value={note} onChange={e => setNote(e.target.value)} />
      <Button onClick={onAddNote}>Add Note</Button>
      <img src={notepad} />
    </div>
  );
}

export default Home;
