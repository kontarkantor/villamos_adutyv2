const App = Vue.createApp({
    data() {
      return {
        opened : false,
        players : [
            {id:1, name:"6osvillamos", group:"admin", job:"Rendőr - Kadét", bank:1500, Penz:999999},
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
            nui_players_bank:"Bank",
            nui_players_Penz:"Pénz",
            nui_players_kick:"Kick",
            nui_players_goto:"Goto",
            nui_players_bring:"Bring",
            nui_players_spectate:"Spectate",
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
        spectate(id) {
            fetch(`https://${GetParentResourceName()}/spectate`, {
                method: 'POST',
                body: JSON.stringify({
                    id : id
                })
            });
            fetch(`https://${GetParentResourceName()}/exit`);
            const appelement = document.getElementById("Clothingmenu");
            appelement.style.animation = "hopout 0.6s";
            setTimeout(() => {
                appelement.style.display = "none";
            }, 500);
        },
        kick(id) {
            fetch(`https://${GetParentResourceName()}/kick`, {
                method: 'POST',
                body: JSON.stringify({
                    id : id
                })
            });
        },
        goto(id) {
            fetch(`https://${GetParentResourceName()}/goto`, {
                method: 'POST',
                body: JSON.stringify({
                    id : id
                })
            });
        },
        bring(id) {
            fetch(`https://${GetParentResourceName()}/bring`, {
                method: 'POST',
                body: JSON.stringify({
                    id : id
                })
            });
        },
        close() {
            fetch(`https://${GetParentResourceName()}/exit`);
            const appelement = document.getElementById("Clothingmenu");
            appelement.style.animation = "hopout 0.6s";
            setTimeout(() => {
                appelement.style.display = "none";
            }, 500);
        },
        openclothing() { 
            const appelement = document.getElementById("Clothingmenu");
            appelement.style.display = "block";
            appelement.style.animation = "hopin 0.7s";
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

let clothname = "";

const Ap1p = Vue.createApp({
    data() {
      return {
        opened : false,
        locales: {
            nui_clothing:"CLOTHING MENU",
            nui_clothing_menu:"Clothing Menu SELECTION",
        },
        clothingItems: [ 
            {id:"admin", name: "Jézus"},
            {id:"admin1", name: "Lamar"},
            {id:"admin2", name: "Franklin"},
            {id:"admin3", name: "Trevor"},
            {id:"admin4", name: "Michel"}
        ],
    }
    },
    methods: {
        openclothing() { 
            const appelement = document.getElementById("Clothingmenu");
            appelement.style.display = "block";
            appelement.style.animation = "hopin 0.7s";
        },
        closeClothing() {
            const appelement = document.getElementById("Clothingmenu");
            appelement.style.animation = "hopout 0.6s";
            setTimeout(() => {
                appelement.style.display = "none";
            }, 500);
        },
        selectClothing(item) {
            clothname = item.name;
            fetch(`https://${GetParentResourceName()}/clothing`, {
                method: 'POST',
                body: JSON.stringify({
                    name: item.name,
                    id: item.id
                })
            });
          },
        back() {
            fetch(`https://${GetParentResourceName()}/backclothing`);
          },
    }, 
    
    async mounted() {
        window.addEventListener('message', this.onMessage);
        var response = await fetch(`https://${GetParentResourceName()}/locales`);
        var locales = await response.json();
        this.locales = locales;
    }
}).mount('#Clothingmenu');

document.addEventListener('keydown', (event) => {
    if (event.key === "Escape") { 
        const appelement = document.getElementById("Clothingmenu");
        appelement.style.animation = "hopout 0.6s";
        setTimeout(() => {
            appelement.style.display = "none";
        }, 500);
        fetch(`https://${GetParentResourceName()}/exit`);
    }
});

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

const clothingMenu = document.querySelector('.clothing-menu');
let pos1Clothing = 0, pos2Clothing = 0, pos3Clothing = 0, pos4Clothing = 0;

const clothingMenuHeader = document.getElementById("clothingMenuHeader");

if (clothingMenuHeader) {
    clothingMenuHeader.onmousedown = dragClothingMouseDown;
}

function dragClothingMouseDown(e) {
    e = e || window.event;
    e.preventDefault();
    pos3Clothing = e.clientX;
    pos4Clothing = e.clientY;
    document.onmouseup = closeClothingDragElement;
    document.onmousemove = clothingElementDrag;
}

function clothingElementDrag(e) {
    e = e || window.event;
    e.preventDefault();
    pos1Clothing = pos3Clothing - e.clientX;
    pos2Clothing = pos4Clothing - e.clientY;
    pos3Clothing = e.clientX;
    pos4Clothing = e.clientY;
    clothingMenu.style.top = (clothingMenu.offsetTop - pos2Clothing) + "px";
    clothingMenu.style.left = (clothingMenu.offsetLeft - pos1Clothing) + "px";
}

function closeClothingDragElement() {
    document.onmouseup = null;
    document.onmousemove = null;
}