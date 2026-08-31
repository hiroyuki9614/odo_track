import axios from 'axios';

const OVERLAY_ID = 'odo-track-axios-loading-overlay';
const STYLE_ID = 'odo-track-axios-loading-style';
let activeRequests = 0;

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

const shouldTrack = config => {
	const method = (config.method || 'get').toLowerCase();
	return method === 'get' && config.skipGlobalLoading !== true;
};

axios.interceptors.request.use(
	config => {
		if (shouldTrack(config)) {
			config.__odoTrackLoading = true;
			showLoading();
		}
		return config;
	},
	error => Promise.reject(error),
);

axios.interceptors.response.use(
	response => {
		if (response.config?.__odoTrackLoading) hideLoading();
		return response;
	},
	error => {
		if (error.config?.__odoTrackLoading) hideLoading();
		return Promise.reject(error);
	},
);
