function toggleSource(link) {
  var method_name = link.dataset.method;
  var source      = document.getElementById(`source-${method_name}`);

  if (source.style.display == 'block') {
    link.innerHTML = 'Show source';
    source.style.display = 'none';
  } else {
    source.style.display = 'block';
    link.innerHTML = 'Hide source';
  }
}

function hlt(string) {
  return stripHTML(string).replace(/\u0001/g, '<strong>')
                          .replace(/\u0002/g, '</strong>');
}

function stripHTML(html) {
  var in_tag = false;
  var output = "";

  for (var i = 0; i < html.length; i++) {
    if (html[i] == '<'){
      in_tag = true;
    } else if (html[i] == '>') {
      in_tag = false;
      i++;
    }

    if (!in_tag && i < html.length)
      output += html[i];
  }

  return output;
}

function logError(e, action) {
  console.error(`Error trying to ${action} 'versions.json':`);
  console.error(e);
}

document.addEventListener("DOMContentLoaded", function() {
  // Properly bind clicks on "View source" links to display the
  // source code.
  var source_links = document.querySelectorAll('a[data-method]');

  if (source_links.length) {
    source_links.forEach(function(link) {
      link.onclick = function() {
        toggleSource(link);
        return false;
      }
    })
  }

  // Build the version picker.
  //
  // We first try to fetch the `versions.json` file at the root
  // of the repository.
  //
  // Then, if present, we build the `<option>` tags and properly
  // redirect when the user clicks on them.
  fetch('/versions.json').then((response) => {
    response.json().then((json) => {
      let version_links = json.map(v => `<option value="v${v}">${v}</option>`);
      let picker = document.querySelector('.version select');

      picker.innerHTML += version_links.join('');

      let hostname = window.location.hostname;
      let protocol = window.location.protocol;

      let host = protocol.concat('//').concat(hostname);

      picker.querySelectorAll('option').forEach(function(el) {
        el.onclick = function() {
          window.location = host.concat(`/${this.value}`);
        }
      });
    }).catch(e => logError(e, 'parse'));
  }).catch(e => logError(e, 'fetch'));

  let searcher = new Searcher(search_data.index);
  let results_div = document.querySelector('.search-results');

  // In case the user is searching for a method that is on the page,
  // the browser won't issue a new request since it will consider it
  // as an anchor so let's hide the search results.
  results_div.onclick = function() {
    this.style.display = 'none';
  }

  searcher.ready(function(results, isLast) {
    if (!results.length) {
      results_div.style.display = 'none';
      return;
    } else {
      results_div.style.display = 'block';
    }

    console.log(results);

    // let ten_firsts  = results.filter((_, index) => index <= 9);

    results_div.innerHTML = '';

    results.forEach((result) => {
      let html = `
        <a href="${path_prefix}${result.path}" class="result">
          <div class="title">${hlt(result.title)}</div>
          <div class="module-class">${hlt(result.namespace)}</div>
          <div class="description">${hlt(result.snippet)}</div>
        </a>
      `;

      results_div.innerHTML += html;
    });
  });

  // Trigger the search whenever the user enters a value in the
  // field.
  document.getElementById('search_field').onkeyup = function(e) {
    if (!this.value) {
      results_div.style.display = 'none';
      return;
    }

    // console.log(e.keyCode);

    searcher.find(this.value);
  }
});
