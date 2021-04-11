const NoteBox = artifacts.require('NoteBoxFactory')

module.exports = async callback => {
    const dnd = await NoteBox.deployed()
    console.log('Let\'s get the overview of your noteBox!')
    const overview = await dnd.noteboxes(0)
    console.log(overview)
    callback(overview.tx)
}
