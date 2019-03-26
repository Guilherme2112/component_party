# Welcome to actioncomponent gem

[![Travis](https://travis-ci.com/viniciusoyama/actioncomponent.svg?branch=master)](https://travis-ci.com/viniciusoyama/actioncomponent)
[![Code Climate](https://codeclimate.com/github/viniciusoyama/actioncomponent/badges/gpa.svg)](https://codeclimate.com/github/viniciusoyama/actioncomponent)
[![Test Coverage](https://codeclimate.com/github/viniciusoyama/actioncomponent/badges/coverage.svg)](https://codeclimate.com/github/viniciusoyama/actioncomponent)

Frontend components for Ruby on Rails: group your view logic, html, css and javascript files in components to be used in views or directly rendered from controllers.

# How to use?

**Gemfile**
```ruby
gem 'actioncomponent'
```

# What do you get?

## Organize your frontend code
Your can group your frontend stuff by domain and organize the UI of your Rails app like this:

```
app
├── components
│   └── user
│       └── filter
│           └── template.html.erb
│           └── view_model.rb
│           └── style.sass
│       └── list
│           └── template.html.erb
│           └── style.sass
```


And, in your views, or in your components, your can render it!

**app/view/users/index.html.erb**

```html
<%
  import_action_component 'Filter', path: 'user/filter'
  import_action_component 'List', path: 'user/list'
%>

<%= Filter() %>

<%= List(users: @users) %>
```

Or, you can completely drop your view and tell your controller to render a User Index Compoment

```
app
├── components
│   └── user
│       └── filter
│           └── template.html.erb
│       └── list
│           └── template.html.erb
│       └── index
│           └── template.html.erb
```


**app/components/user/index/template.html.erb**

```html
<%
  import_action_component 'Filter', path: 'user/filter'
  import_action_component 'List', path: 'user/list'
%>

<%= Filter() %>

<%= List(users: @users) %>
```

**app/controllers/users_controller.rb**

```ruby

class ClientsController < ApplicationController

  def index
    # Will search in
    # components/pages/clients/index
    render component: true, view_model_data: { clients: Client.all }
  end

end


```

## Pass data to your components in your templates

When rendering your can pass data in a hash/named parameters format. The data will be exposed in your template through a view model.  

Supose that you have a header component

```
app
├── components
│   └── header
│       └── template.html.erb
```

And you want to render this component in your layout file.

**app/views/layouts/application.html.erb**

```html

<%
  import_action_component 'Header', path: 'header'
%>

<%= Header(my_user: current_user) %>
```

You can access the user attribute in your template like this:

**app/components/header/template.html.erb**

```html
<header>
  Hi, <%= my_user.name %>
</header>
```

## View Models

The methods available inside the template will be those defined in your view model. If no view model is defined for your component then our ActionComponent::Component::ViewModel will be used. The view model is instantiated with the arguments that you provide when calling your component.

### ActionComponent::Component::ViewModel

It takes all the constructor arguments (it must be a hash/named args) and creates a getter for each one of them. Example:

```ruby
vm = ActionComponent::Component::ViewModel.new(name: 'John', age: 12)
vm.name # John
vm.age # 12
```

### Create your own ViewModel: handle complex view logic

We only use our own view model if there is no view_model.rb file inside your component's folder. This file should declare a class following all the Rails naming conventions.

So, imagine that we want our vm to have a random_greeting method. We can can create a view model like this:


## Use helpers inside your components

When initializing the view model we also provide two additionals parameters (:h and :helper) so you can have access to rails helpers.

As all view model methods are available to your template your will have access to a `h` or `helper` like this:

**Example of a component's templatefile**

```
<div class="child">
  <div class="date">
    <%= helper.l(Date.new(2019, 01, 03)) %>
  </div>

  <div class="routes">
    <%= h.users_path %>
  </div>

  <div class="translation">
    <%= h.t('hello')%>
  </div>
</div>
```

Your can create custom view models that inherits from ours

**app/components/header/view_model.rb**

```ruby
class Header::ViewModel < ActionComponent::Component::ViewModel
  def random_greeting
    hi_text = ['Hi', 'Yo'].sample
    "#{hi_text}, #{user.name}"
  end
end
```

Now the template can access the method like this:

**app/components/header/template.html.erb**
```html
<header>
  <%= random_greeting %>
</header>
```

### Use helpers inside a ViewModel

A `helper` and `h` attribute are passed when instantiating a ViewModel.

```ruby
class Header::ViewModel < ActionComponent::Component::ViewModel
  def random_greeting
    hi_text = ['Hi', 'Yo'].sample
    "#{hi_text}, #{user.name}."
  end

  def formated_date
    h.l(Date.today)
  end
end
```

**app/components/header/template.html.erb**
```html
<header>
  <%= random_greeting %> Today is <%= formated_date %>
</header>
```


## Access your controller in your VM or Template

When rendering a component, a `c` or `controller` parameter is passed through so you can have access to all your request data inside your VM or template.

**view_model**

```ruby
class ControllerData::ViewModel < ActionComponent::Component::ViewModel

  def formated_page
    "Current page: #{c.params[:page]}"
  end

  def formated_search
    "Searching for: #{controller.params[:search]}"
  end

end
```

**template.erb**

```html
<%= formated_search %>

<%= formated_page %>
```

# Rendering from a controller

When you are inside an action you can render a component using the following syntax:

```ruby
render(component: 'my/component/path', view_model_data: { new_arg: 2, more_arg: 'text'})
```

If you want to render the default component for an given action (just like rails automatically renders you views) you can write:


```ruby
class ClientsController < ApplicationController

  def index
    # Will search in
    # components/pages/clients/index
    render component: true, view_model_data: { clients: Client.all }
  end

end
```

Note that, differently from rails, we will add a 'pages' folder at the beginning of your path. This is done so you can can have isolated components that represents each action in a isolated namespace.

## How to render component pages insted of views by default?

Just call 'render_components_by_default!' inside your controller. If you want all your controllers to behave like this you can put this command in your ApplicationController:

```ruby
class ApplicationController < ActionController::Base
  render_components_by_default!
end

```

This is not a global in order to keep compatibility with other gems like Devise that does not support this gem.

**PS:** Your mailers will still use views and not components 


# Style namespacing

Each rendered component will be wrapped inside a div with a dynamic data attribute according to the component path. This means that you can create custom css for each component. Example:


```
app
├── components
│   └── user_page
│       └── header
│           └── template.html.erb
```

If we render the header inside a component it will generate a HTML like this

```html

<div class='action-component' data-action-component-id='user_page-header'>
  ...
  ...
</div>

```

Then you can customize the component with the following css:

```css
[data-action-component-id=project-index] {
  background: red;
}
```

## Where do I put my CSS files?

Where it belongs: in your component folder. It doens't matter the name or de number of css/sass/less files that you have... Just don't forget to namespace it!

Also in your application.css file you should require all the css from the component folder. You can do that with a relative `require_tree`. Like this:

**application.sass**

```sass
//*=require_tree ../../../components
@import "fullcalendar.min"
@import "bootstrap"
@import "datepicker"

// ...
```



# Configuration

You can change some parameters by creating a initializer on your app

**config/initializers/action_component.rb**


```ruby

ActionComponent.configure do |config|
  # Folder path to look for components
  config.components_path = 'app/components'

  # Default name for the html/erb/slim/etc template file inside the component folder
  config.template_file_name = 'template'

  # Default name for the view model file inside the component folder
  config.view_model_file_name = 'view_model'

  # Default folder path inside the components folder to look for when
  # rendering the default component for an action inside a controller
  config.component_folder_for_actions = 'pages'
end

```
