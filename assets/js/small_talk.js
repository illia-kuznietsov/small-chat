let SmallTalk = {
    init(socket) {
        let channel = socket.channel("small_talk:lobby", {})
        channel.join()
        this.listenForChats(channel)
    },

    listenForChats(channel) {
        document.getElementById('chat-form').addEventListener('submit', function(e){
            e.preventDefault()

            let userMsg = document.getElementById('user-msg').value

            channel.push('shout', {body: userMsg})

            document.getElementById('user-msg').value = ''
        })

        channel.on('shout', payload => {
            let chatBox = document.querySelector('#chat-box')
            let msgBlock = document.createElement('p')

            msgBlock.insertAdjacentHTML('beforeend', `message: ${payload.body}`)
            chatBox.appendChild(msgBlock)
        })
    }
}

export default SmallTalk