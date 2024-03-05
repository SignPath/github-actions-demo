import Vivus from 'vivus';
import Typed from 'typed.js';

document.addEventListener('DOMContentLoaded', function() {
	new Vivus('logo', {duration: 100} );

	new Typed('#slogan', {
      strings: ['Built. Signed. Delivered.'],
      typeSpeed: 50,
      showCursor: false,
      autoInsertCss: false
    });
});