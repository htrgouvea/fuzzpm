const puppeteer = require("puppeteer");
const fs = require("fs");
const jsdom = require("jsdom");

const { JSDOM } = jsdom;

// We need to hook every tab that is opened and then listen for responses and requests on each tab.
const hookNewPages = browser => {
	browser.on("targetcreated", async target => {
		try {
			const page = await target.page();
			hookResponse(page);
			hookRequest(page);
		}

		catch {
			// Sometimes setting a bypass for CSP will error out.
		}
	})
}

// We hook the response and then handle it appropriately.
const hookResponse = page => {
	try {
		page.on("response", response => handleResponse(response, page));
	} catch {
		// Some type of responses can't be hooked (like downloads).
	}
}

// We hook the request and then handle it appropriately.
const hookRequest = page => {
	try {
		page.on("request", request => handleRequest(request))
	} catch {
		// Some type of requests can't be hooked (like downloads).
	}
}

const isAuthenticated = response => {
	let authKeys = [
		"Heitor",
		"htrgouvea",
		"heitor",
		"Gouvêa",
		"hi@heitorgouvea.me"
		// We can make regex for CPFs, SSN, CC's and physcal address
	]

	for (let value of authKeys) {
		if (response.includes(value)) {
			return true;
		}
	}

	return false;
}

const handleResponse = async (response, page) => {
	try {
		let url = await response.url();
		let headers = await response.headers();
		let method = await response.request().method();
		let data = await response.text();
		let status = await response.status();
		let newHeaders = {}

		Object.entries(headers).map(([key, value]) => {
			newHeaders[key] = value.toLowerCase();
		});

		let content_type = newHeaders["content-type"] || "";
		let x_frame_options = newHeaders["x-frame-options"] || "";
		let x_content_type_options = newHeaders["x-content-type-options"] || "";


		const conditions = [
			{
				cd: isAuthenticated(data) && x_frame_options == "" && content_type.includes("text/html"),
				type: "Clickjacking" // Potential Clickjacking with PII exfiltration.
			},
			{
				cd: isAuthenticated(data) && (content_type.includes("application/javascript") || !x_content_type_options.includes("nosniff")),
				type: "XSSI" // Warn about XSSI.
			},
			{
				cd: content_type === "" && !x_content_type_options.includes("nosniff") && status !== 204,
				type: "MIME" // Warn about potential MIME vulnerability.
			},
			{
				cd: x_frame_options !== "" && !x_frame_options.includes("deny") && !x_frame_options.includes("sameorigin") && status !== 204,
				type: "ODD_XFO" // Warn about odd XFO.
			},

		]

		conditions.forEach(({ cd, type }) => {
			if (cd) {
				// do everything you want. 
				console.log({ url, status, method, type })
			}
		})


		let dom = new JSDOM(data);
		try {
			let links = dom.window.document.getElementsByTagName("a");

			for (let i = 0; i < links.length; i++) {
				// console.log(links[i].href);
				fs.appendFileSync("output/links.txt", links[i].href + "\n");
			}
		}

		catch {
			//
		}

		try {
			let iframes = dom.window.document.getElementsByTagName("iframe");

			for (let i = 0; i < iframes.length; i++) {
				// console.log(iframes[i].src);
				fs.appendFileSync("output/links.txt", iframes[i].src + "\n");
			}
		}

		catch {
			// 
		}

		// console.log(url);
		fs.appendFileSync("output/links.txt", url + "\n");

	}

	catch {
		// Redirects don't have a body and have to be handled separetaly.
	}
}

const handleRequest = async request => {
	try {
		let headers = await request.headers();
		let newHeaders = {};

		Object.entries(headers).map(([key, value]) => {
			newHeaders[key] = value.toLowerCase();
		});
	}

	catch {
		// Redirects don't have a body and have to be handled separetaly.
	}
}

(async () => {
	const browser = await puppeteer.launch({
		headless: false,
		defaultViewport: null
	});
	await hookNewPages(browser);

	const page = await browser.newPage();
	await page.goto("https://heitorgouvea.me/");
})();