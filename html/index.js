const App = Vue.createApp({
    data() {
      return {
        opened : false,
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
        locales: {
            nui_label:"ADMIN DUTY PANEL",
            nui_group:"Your group",
            nui_players:"Players",
            nui_duty:"Duty",
            nui_tag:"Admin tag",
            nui_esp:"Show IDs",
            nui_god:"God mode",
            nui_speed:"Speed",
            nui_invisble:"Invisible",
            nui_noragdoll:"No Ragdoll",
            nui_coords:"Coords",
            nui_health:"Health",
            nui_marker:"Marker",
            nui_label_players:"PLAYERS",
            nui_players_refresh:"Refresh",
            nui_players_search:"Search for name, group, ID or job",
            nui_players_id:"ID",
            nui_players_name:"Name",
            nui_players_group:"Group",
            nui_players_job:"Job",
        },

        search : ""
      }
    },
    computed: {
        filteredList() {
            if (this.search == "") return this.players;

            const lowsearch = this.search.toLowerCase()

            return this.players.filter((player) => {
                return player.name.toLowerCase().includes(lowsearch) || player.group.toLowerCase() == lowsearch || player.job.toLowerCase() == lowsearch || player.id.toString() == lowsearch;
            });
        }
    },
    methods: {
        onMessage(event) {
            if (event.data.type == "show") {
                const appelement = document.getElementById("app");
                if (event.data.enable) {
                    appelement.style.display = "block";
                    appelement.style.animation = "hopin 0.7s";
                    this.opened = true;
                } else {
                    appelement.style.animation = "hopout 0.6s";
                    this.opened = false;
                    setTimeout(() => {
                        if (!this.opened) appelement.style.display = "none";
                    }, 500);
                }
            } else if (event.data.type == "setplayers") {
                this.players = event.data.players;
            } 
            else if (event.data.type == "setstate") {
                this.state = event.data.state;
            }
            else if (event.data.type == "copy") {
                this.copytoclipboard(event.data.copy);
            }
        },
        copytoclipboard(txt) {
            var textArea = document.createElement("textarea");
            textArea.value = txt;
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
        },
        close() {
            fetch(`https://${GetParentResourceName()}/exit`);
        },
        update() {
            fetch(`https://${GetParentResourceName()}/update`);
        },
        duty() {
            this.state.duty = !this.state.duty
            fetch(`https://${GetParentResourceName()}/duty`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.duty
                })
            });
        },
        tag() {
            this.state.tag = !this.state.tag
            fetch(`https://${GetParentResourceName()}/tag`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.tag
                })
            });
        },
        ids() {
            this.state.ids = !this.state.ids
            fetch(`https://${GetParentResourceName()}/ids`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.ids
                })
            });
        },
        god() {
            this.state.god = !this.state.god
            fetch(`https://${GetParentResourceName()}/god`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.god
                })
            });
        },
        speed() {
            this.state.speed = !this.state.speed
            fetch(`https://${GetParentResourceName()}/speed`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.speed
                })
            });
        },
        invisible() {
            this.state.invisible = !this.state.invisible
            fetch(`https://${GetParentResourceName()}/invisible`, {
                method: 'POST',
                body: JSON.stringify({
                    enable : this.state.invisible
                })
            });
        },
        noragdoll() {
            this.state.noragdoll = !this.state.noragdoll
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
    async mounted() {
        window.addEventListener('message', this.onMessage);
        var response = await fetch(`https://${GetParentResourceName()}/locales`);
        var locales = await response.json();
        this.locales = locales;
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