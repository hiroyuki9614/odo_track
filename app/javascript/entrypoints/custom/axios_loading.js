import axios from 'axios';

const OVERLAY_ID = 'odo-track-axios-loading-overlay';
const STYLE_ID = 'odo-track-axios-loading-style';
const CACHEABLE_PATHS = new Set([
	'/api/daily_logs/',
	'/api/daily_logs_for_admin/',
]);

let activeRequests = 0;
let cacheGeneration = 0;
const responseCache = new Map();

const cloneData = value => {
	if (value === undefined || value === null) return value;
	if (typeof structuredClone === 'function') return structuredClone(value);
	return JSON.parse(JSON.stringify(value));
};

const requestMethod = config => (config.method || 'get').toLowerCase();

const requestUrl = config => {
	try {
		return new URL(config.url || '', config.baseURL || window.location.origin);
	} catch (_error) {
		return null;
	}
};

const isCacheableRequest = config => {
	if (requestMethod(config) !== 'get') return false;
	const url = requestUrl(config);
	return url ? CACHEABLE_PATHS.has(url.pathname) : false;
};

const cacheKeyFor = config => {
	const url = requestUrl(config);
	if (!url) return config.url || '';

	const searchParams = new URLSearchParams(url.search);
	if (config.params && typeof config.params === 'object') {
		Object.entries(config.params)
			.sort(([left], [right]) => left.localeCompare(right))
			.forEach(([key, value]) => {
				if (Array.isArray(value)) {
					value.forEach(item => searchParams.append(key, item));
				} else if (value !== undefined && value !== null) {
					searchParams.set(key, value);
				}
			});
	}

	const query = searchParams.toString();
	return query ? `${url.pathname}?${query}` : url.pathname;
};

const invalidateCache = () => {
	cacheGeneration += 1;
	responseCache.clear();
};

const ensureLoadingStyle = () => {
	if (document.getElementById(STYLE_ID)) return;

	const style = document.createElement('style');
	style.id = STYLE_ID;
	style.textContent = `
		@keyframes odo-track-loading-spin {
			to { transform: rotate(360deg); }
		}

		#${OVERLAY_ID} {
			position: fixed;
			inset: 0;
			display: none;
			align-items: center;
			justify-content: center;
			background: rgba(255, 255, 255, 0.72);
			backdrop-filter: blur(1px);
			z-index: 2147483647;
		}

		#${OVERLAY_ID} .odo-track-loading-content {
			display: flex;
			flex-direction: column;
			align-items: center;
			gap: 12px;
			font-weight: 600;
		}

		#${OVERLAY_ID} .odo-track-loading-spinner {
			width: 42px;
			height: 42px;
			border: 4px solid rgba(0, 0, 0, 0.16);
			border-top-color: currentColor;
			border-radius: 50%;
			animation: odo-track-loading-spin 0.8s linear infinite;
		}
	`;
	document.head.appendChild(style);
};

const ensureOverlay = () => {
	let overlay = document.getElementById(OVERLAY_ID);
	if (overlay) return overlay;
	if (!document.body) return null;

	ensureLoadingStyle();

	overlay = document.createElement('div');
	overlay.id = OVERLAY_ID;
	overlay.setAttribute('role', 'status');
	overlay.setAttribute('aria-live', 'polite');
	overlay.setAttribute('aria-label', '読み込み中');
	overlay.innerHTML = `
		<div class="odo-track-loading-content">
			<div class="odo-track-loading-spinner" aria-hidden="true"></div>
			<span>読み込み中...</span>
		</div>
	`;
	document.body.appendChild(overlay);

	return overlay;
};

const showLoading = () => {
	activeRequests += 1;
	const overlay = ensureOverlay();
	if (!overlay) return;

	overlay.style.display = 'flex';
	overlay.setAttribute('aria-hidden', 'false');
	document.body.setAttribute('aria-busy', 'true');
};

const hideLoading = () => {
	activeRequests = Math.max(0, activeRequests - 1);
	if (activeRequests > 0) return;

	const overlay = document.getElementById(OVERLAY_ID);
	if (overlay) {
		overlay.style.display = 'none';
		overlay.setAttribute('aria-hidden', 'true');
	}

	document.body?.removeAttribute('aria-busy');
};

const refreshInBackground = config => {
	const refreshConfig = {
		method: 'get',
		url: config.url,
		baseURL: config.baseURL,
		params: config.params,
		headers: config.headers,
		withCredentials: config.withCredentials,
		skipSpaCache: true,
		skipGlobalLoading: true,
	};

	Promise.resolve()
		.then(() => axios.request(refreshConfig))
		.catch(error => {
			console.debug('Background refresh failed:', error);
		});
};

axios.interceptors.request.use(
	config => {
		if (requestMethod(config) !== 'get') {
			invalidateCache();
			return config;
		}

		if (!isCacheableRequest(config)) return config;

		const cacheKey = cacheKeyFor(config);
		config.__odoTrackCacheKey = cacheKey;
		config.__odoTrackCacheGeneration = cacheGeneration;

		if (config.skipSpaCache !== true) {
			const cachedResponse = responseCache.get(cacheKey);
			if (cachedResponse) {
				config.__odoTrackFromCache = true;
				config.__odoTrackLoading = true;
				showLoading();
				config.adapter = async () => ({
					data: cloneData(cachedResponse.data),
					status: cachedResponse.status,
					statusText: cachedResponse.statusText,
					headers: cachedResponse.headers,
					config,
					request: null,
				});
				queueMicrotask(() => refreshInBackground(config));
				return config;
			}
		}

		if (config.skipGlobalLoading !== true) {
			config.__odoTrackLoading = true;
			showLoading();
		}
		return config;
	},
	error => Promise.reject(error),
);

axios.interceptors.response.use(
	response => {
		if (
			isCacheableRequest(response.config) &&
			response.config.__odoTrackFromCache !== true &&
			response.config.__odoTrackCacheGeneration === cacheGeneration
		) {
			const cacheKey = response.config.__odoTrackCacheKey || cacheKeyFor(response.config);
			responseCache.set(cacheKey, {
				data: cloneData(response.data),
				status: response.status,
				statusText: response.statusText,
				headers: response.headers,
			});
		}

		if (response.config?.__odoTrackLoading) hideLoading();
		return response;
	},
	error => {
		if (error.config?.__odoTrackLoading) hideLoading();
		return Promise.reject(error);
	},
);
