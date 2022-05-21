# Pisces Dashboard stylesheet tweek for wide screens

**To Run:**

Open an ssh session to your Pisces Miner and sign in as admin user. Copy/Paste this command in the session:

wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_css_patch/patch_css.sh -O - | sudo bash

**What this patch does**

This patch adds a media query to the end of the css so that when the screen is wider than 768 pixels, the width becomes auto. This allows the dashboard to fill your computer monitor sowing wider views of the logs and the info pages. It has no effect on mobile browsers since their width is less than 768 pixels.

**What if you don't like the change**

The patch process makes a copy of your css file befor applying the patch. You may revert back to the original css with the following ssh command:

sudo cp /var/dashboard/public/css/common.css.orig /var/dashboard/public/css/common.css

**No Changes Visible**

Press Ctrl-F5 (PC) Cmd-F5 (Mac) in browser while on the Pisces Dashboard to cause the browser to reload the css file. Or close the browser and reopen.

### Screen Capture of the Dashboard before the patch

![Dashboard with Original CSS](original-dashboard.png)

### Screen Capture of the Dashboard after the patch
![Dashboard with new media query](pisces-dashboard-after.png)
