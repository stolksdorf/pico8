const fs = require('fs');
const { exec } = require("child_process");


const Cart = process.argv[2];

if(!Cart) throw 'Must enter a cart as a commandline arg';


exec(`C:/root/Tools/Software/pico8/pico8.exe -windowed 1 -run C:/root/Programming/pico8/${Cart}.p8`);


const debounce = (fn, t=16)=>function(...args){clearTimeout(this.clk);this.clk=setTimeout(()=>fn(...args),t);};


let code = fs.readFileSync(`${Cart}.p8`, 'utf8');

let tabs = [];


let pauseTabs = false;
let pauseCart = false;


const update = ()=>{
	tabs = fs.readFileSync(`${Cart}.p8`, 'utf8').split('\n-->8\n').map((code, idx)=>{
		code = code.trim()
		let name = code.split('\n')[0].replace('--', '');

		if(name.indexOf(' ')!==-1) name = idx;
		if(idx == 0) name ='init';

		const path = `./${Cart}/${name}.lua`;

		fs.writeFileSync(path, code);

		return {code, name, path};
	});
}

update();

tabs.map(({path, name}, idx)=>{
	fs.watch(path, debounce((evt)=>{
		if(pauseTabs) return;

		tabs[idx].code = fs.readFileSync(path, 'utf8');
		pauseCart = true;
		fs.writeFileSync(`${Cart}.p8`, tabs.map(({code})=>code).join('\n-->8\n'));
		console.log(`tab: ${name} updated.`)

		setTimeout(()=>pauseCart = false, 100);
	}))
});


fs.watch(`${Cart}.p8`, debounce(()=>{
	if(pauseCart) return;
	console.log('Cart updated')

	pauseTabs = true;
	update();
	setTimeout(()=>pauseTabs = false, 100);
}))




console.log(`Watching ${Cart}`);

