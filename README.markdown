# Deployment Recipes #

A collection of [Capistrano]() / [Websitrano]() recipes for use with common software and projects. These recipes are designed to be used with common open source projects. Allowing you to deploy them in a controlled and repeatable manner. If used with Webistrano these recipes provide single push button deployment provided with a fully configurable web application interface.

## Non Rails Recipie ##

The non rails recipe overloads the default deployment functionality to make these recipes suitable for specifically PHP projects but can be used to deploy other non Rails / Ruby projects.

Each of the application specific recipes uses this Non Rails recipe as its base.

## Magento Recipe ##

Starting with a deployment recipe for Magento but more will be added in the future. These recipes extend the default Capistrano deployment tasks to meet the needs of specific software projects and additional tasks that may be useful.

The Magento recipe will deploy your application and also link the shared directories to a central location this includes:

    * app/etc/local.xml
    * media
    * sitemaps
    * staging
    * var
    
It will also clear the Magento file based cache following a deployment.

*You may wish to add to this recipe if you are using an alternate cache mechanism to ensure that cache is cleared correctly after deployment.*

## WordPress Recipe ##

The WordPress recipe provides a simple and repeatable mechanism to deploy WordPress based projects. This will create symlinks to all the shared locations to ensure that your uploaded files are maintained between deployments.

    * wp-content/uploads
    * wp-config.php
    * sitemap.xml
    * sitemap.xml.qz
    
*This assumes that you will be using the all-in-one SEO module.*
    
## Showing your appreciation ##

Of course, the best way to show your appreciation for these recipes itself remains
contributing by forking this project.  If you'd like to show your appreciation in
another way, however, consider Flattr'ing me:

[![Flattr this][2]][1]

[1]: http://flattr.com/thing/75871/Capistrano-Webistrano-deployment-recipes-for-Magento-WordPress-and-others
[2]: http://api.flattr.com/button/button-compact-static-100x17.png