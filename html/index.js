const App = Vue.createApp({
    data() {
      return {
        players : [
            {id:1, name:"6osvillamos", group:"admin", job:"Rendőr"},

        ],
        state : {
            group:"user",
            duty:false,
            tag:false,
            ids:false,
            god:false,
            speed:false,
            invisible:false,
            noragdoll:false
        },

        search : ""
      }
    },
    computed: {
        filteredList() {
            if (this.search == "") return this.players;

            const lowsearch = this.search.toLowerCase()

            return this.players.filter((player) => {
                return player.name.toLowerCase().includes(lowsearch) || player.group.toLowerCase() == lowsearch || player.job.toLowerCase() == lowsearch || String(player.id) == lowsearch;
            });
        }
    },
    methods: {
        close() {
            fetch(`https://${GetParentResourceName()}/exit`);
        },
        update() {
            fetch(`https://${GetParentResourceName()}/update`);
        },
        duty() {
            fetch(`https://${GetParentResourceName()}/duty`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.duty
                })
            });
        },
        tag() {
            fetch(`https://${GetParentResourceName()}/tag`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.tag
                })
            });
        },
        ids() {
            fetch(`https://${GetParentResourceName()}/ids`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.ids
                })
            });
        },
        god() {
            fetch(`https://${GetParentResourceName()}/god`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.god
                })
            });
        },
        speed() {
            fetch(`https://${GetParentResourceName()}/speed`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.speed
                })
            });
        },
        invisible() {
            fetch(`https://${GetParentResourceName()}/invisible`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.invisible
                })
            });
        },
        noragdoll() {
            fetch(`https://${GetParentResourceName()}/noragdoll`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.noragdoll
                })
            });
        },
        coords() {
            fetch(`https://${GetParentResourceName()}/coords`);
        },
        heal() {
            fetch(`https://${GetParentResourceName()}/heal`);
        },
        marker() {
            fetch(`https://${GetParentResourceName()}/marker`);
        },
    }, 
    mounted() {
        var _this = this;
        window.addEventListener('message', function(event) {
            if (event.data.type == "show") {
                document.body.style.display = event.data.enable ? "block" : "none";
            } else if (event.data.type == "setplayers") {
                _this.players = event.data.players;
            } 
            else if (event.data.type == "setstate") {
                _this.state = event.data.state;
            }
            else if (event.data.type == "copy") {
                console.log(event.data.copy);
                var textArea = document.createElement("textarea");
                textArea.value = event.data.copy;
                document.body.appendChild(textArea);
                textArea.focus();
                textArea.select();
                document.execCommand('copy');
                document.body.removeChild(textArea);
            }
        });
    }
}).mount('#app');


var elmnt = document.getElementById("app");
var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
if (document.getElementById("appheader")) {
    document.getElementById("appheader").onmousedown = dragMouseDown;
} else {
    elmnt.onmousedown = dragMouseDown;
}

function dragMouseDown(e) {
    e = e || window.event;
    e.preventDefault();
    pos3 = e.clientX;
    pos4 = e.clientY;
    document.onmouseup = closeDragElement;
    document.onmousemove = elementDrag;
}

function elementDrag(e) {
    e = e || window.event;
    e.preventDefault();
    pos1 = pos3 - e.clientX;
    pos2 = pos4 - e.clientY;
    pos3 = e.clientX;
    pos4 = e.clientY;
    elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
    elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
}

function closeDragElement() {
    document.onmouseup = null;
    document.onmousemove = null;
}