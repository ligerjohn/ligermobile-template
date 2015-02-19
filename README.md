# Quick LigerMobile tutorial

## Prerequisites 

### Node

* Install the latest stable version of node
* Install yeoman ```npm install -g yo```
* Install bower ```npm install -g bower```
* Install gulp ```npm install -g gulp```
* ```git clone git@github.com:reachlocal/generator-ligermobile.git```
* Link the generator with ```npm link``` when in the generator-ligermobile repo

### iOS

* Install the latest non-beta xcode
* ```git clone https://github.com/ligerjohn/ligermobile-template.git```
* Type ```open iOS/Template.xcworkspace``` in the repo to open the workspace to verify that it loads (if you try to run it will get stuck in an NSAssert since we haven’t added a javascript app yet).

 
### Android

TBD

## Generate the app

In the ```common``` folder in ```ligermobile-template``` create an app.

```bash
yo ligermobile
```

When the prompt shows up, select tab and press enter.

## cordova.js

The delivery of cordova.js has currently not been solved. Because of this we have to copy a file into the app. This only works for one platform at a time, as the file is different per platform.

Run this in the root of the Template repo:

```bash
cp iOS/Pods/Cordova/CordovaLib/cordova.js common/app/vendor
```

## More pages

Let's add two more pages to the mix. The fastest and easiest way is to generate them:

```bash
yo ligermobile:page contacts page
```
```bash
yo ligermobile:page history page
```

```gulp``` is automatically ran after you generate a page, so everything is compiled and moved over to your ```app``` folder.

## Modify app.json

Having two new pages that you can't see isn't terribly interesting. So let's do something with them. Let's add them to the tab.

You start out with:

```json
        "pages": [
          {
            "name": "Home",
            "title": "Home",
            "page": "navigator",
            "args": {
              "title": "Home",
              "page": "home",
              "args": {},
              "options": {}
            }
          }, {
            "name": "Settings",
            "title": "Settings",
            "page": "navigator",
            "args": {
              "title": "Settings",
              "page": "settings",
              "args": {},
              "options": {}
            }
          }
        ]
```

And end up with:

```json
        "pages": [
          {
            "name": "Home",
            "title": "Home",
            "page": "navigator",
            "args": {
              "title": "Home",
              "page": "home",
              "args": {},
              "options": {}
            }
          }, {
            "name": "Contacts",
            "title": "Contacts",
            "page": "navigator",
            "args": {
              "title": "Contacts",
              "page": "contacts",
              "args": {},
              "options": {}
            }
          }, {
            "name": "History",
            "title": "History",
            "page": "navigator",
            "args": {
              "title": "History",
              "page": "history",
              "args": {},
              "options": {}
            }
          }, {
            "name": "Settings",
            "title": "Settings",
            "page": "navigator",
            "args": {
              "title": "Settings",
              "page": "settings",
              "args": {},
              "options": {}
            }
          }
        ]
```

Restarting the app should now get you four tabs instead of two.

## List of contacts

Let's put something on the contacts page. How about a list of contacts?

### contacts.jst

Add a bootstrap list group in the template.

```
<div class="list-group">
  <% _.each(contacts,function(contact){ %>
  <a class="list-group-item"><span><%= contact %></span></a>
  <% }); %>
</div>
```

Don't forget to run ```gulp``` after you change a page file, such as a template or javascript file. To avoid forgetting, try using ```gulp watch``` that will silently watch for files changing in the background and leap to action when they are.

### contacts.js

Initialize the template with some data. Just an array of strings in this case, but a real life app would more than likely read the data from a server and then add them in via a template. Since we already have the data we don't need to have a temporary UI in place.

```javascript
  initialize: function() {
    // Initialize your page here (set up your HTML, load json from the net, etc).
    var contacts = ['Tom', 'Dick', 'Harry'];
    $("#contacts_container").html(_.template(window.Templates.contacts({contacts:contacts})));
    CONTACTS.addBindings();
  },

  addBindings:function() {
    $('div.list-group a.list-group-item').on('touchstart', function() {
      $(this).addClass('active').siblings().removeClass('active');
    });

    $('div.list-group a.list-group-item').on('touchend', function() {
      $(this).removeClass('active');
    });
  }
```

Running the app again we should have a list on the contact page.

## Contact details

The list is kind of boring though, doesn't do anything. Let's make it open up a new page!

Create a contactDetail page for us to open:

```
yo ligermobile:page contactDetails page
```

### contacts.js

And add in an extra ```PAGE.openPage(...)``` to open the page:

```javascript
  addBindings:function() {
    $('div.list-group a.list-group-item').on('touchstart', function() {
      $(this).addClass('active').siblings().removeClass('active');
    });

    $('div.list-group a.list-group-item').on('touchend', function() {
      $(this).removeClass('active');
      PAGE.openPage('Detail', 'contactDetails', {}, {});
    });
  }
```

## One more thing

Let's send some data over to the newly opened page!

### contacts.jst

Add in the data-contact-item. This way we save away our data for later.

```
<div class="list-group">
  <% _.each(contacts,function(contact){ %>
  <a class="list-group-item" data-contact-item="<%= escape(JSON.stringify(contact)) %>"><span><%= contact %></span></a>
  <% }); %>
</div>
```

### contacts.js

Grab the data out and include it in the args. Args are meant to send data to a page. Options (the next {}) are options for the page. Options are typically handled by the native implementation, to the point where it's not even sent to the javascript. To access your page's args use ```PAGE.args``` after ```initialize```` has been called.

```javascript
  addBindings:function() {
    $('div.list-group a.list-group-item').on('touchstart', function() {
      $(this).addClass('active').siblings().removeClass('active');
    });

    $('div.list-group a.list-group-item').on('touchend', function() {
      $(this).removeClass('active');
      var contactItem = JSON.parse(unescape($(this).data("contact-item")));
      PAGE.openPage('Detail', 'contactDetails', {contact:contactItem}, {});
    });
```

## Done!

This simple demonstration is now over. Feel free to play more with the app and see what it can do. There's more functionality available in PAGE, and there's a number of built in native pages available as well. [Look at the Liger documentation](https://github.com/reachlocal/liger) for more info and don't be shy about pull requests if something is either wrong or missing.
