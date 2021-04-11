const NoteBox = artifacts.require('NoteBoxFactory')

module.exports = async callback => {
  const dnd = await NoteBox.deployed()
  console.log('Creating requests on contract:', dnd.address)
  const tx = await dnd.requestNewRandomNoteBox(77, "This Note Might Be Burnable")
  callback(tx.tx)
}
