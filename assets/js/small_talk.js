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

            msgBlock.insertAdjacentHTML('beforeend', `${payload.nickname} : ${payload.message}`)
            chatBox.appendChild(msgBlock)
        })

        let like_buttons = document.getElementsByClassName('like');
        for (b of like_buttons){
             b.addEventListener('onclick', function(e){
                 channel.push('like', {id: e.id})
             });
        }

        channel.on('like', payload => {
            let button = document.getElementById(payload.id)
            button.setAttribute(title, payload.likes)
            button.value = payload.likes.length
        })
    }
}

export default SmallTalk