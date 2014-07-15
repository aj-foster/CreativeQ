# CreativeQ

CreativeQ is a work order management system for the Office of Student Involvement at UCF. Students involved with one of the office's several student-run agencies can use this system to request graphic designs, website work, and video productions. Professional staff advisors can approve the orders and monitor their progress.

Stemming from a similar graphics-only work order system called DesignQ (constructed by [Bill Columbia](http://billcolumbia.me) during his time at OSI), CreativeQ is shaped largely by the dynamics of OSI. Organizations funded by the school's student government can submit orders for OSI's Creative Services to complete. Currently, Creative Services consists of 8 graphic designers, 2 web designers / developers, and 5 video productions staff - all students at the University. These students claim the orders once they've been approved by the organization's advisor, and complete them before the specified deadline. CreativeQ standardizes the work order process in a lively office.


## Technical Details

CreativeQ is built using Ruby on Rails. We chose Rails as it provides an accessible way to accomplish such an object-oriented task as handling work requests. Here is a breakdown of the model scheme:

* **Orders** can be one of three types (graphics, web, or production) and are defined by their description, needs, and due date.
* **Organizations** represent the groups submitting work orders. Each organization has one or more advisor who approves all orders submitted.
* **Users** are the people in the process.
	* *Basic Users* can create orders and track their progress. Some may be assigned as the advisors of their agencies.
	* *Creatives* can claim orders from the queue and update their status (started, proofing, revising, complete) as they go.
	* *Administrators* get a bird's-eye view of all the orders and their progress. Traditionally, the professional staff involved with Creative Services ensure that everything proceeds smoothly.

*Note: As professional staff members may advise multiple agencies, there also exists an Assignments model that joins Users and Organizations. It includes a role description that determines whether the user acts as a member or advisor.*


## Reflections

A detailed reflection can be found [on my website](http://aj-foster.com/reflections/creativeq-reflection.html). CreativeQ was quite fun to build, and it's my first Rails project to see production.

**Later Features**

* Although the scale of this application is relatively small, a data-retention policy would help the longevity of the system. Students in the office have a high turnover rate as compared to career professionals, and the office has decided that 3 years is long enough to keep their data. A monthly cron-like feature could 1) warn administrators of the Users to be removed next month and 2) automatically remove users whose updated_at dates are greater than three years. Something similar can be done with old orders.
* Attaching files to orders is one of the most popular requests. This is not difficult to do, but it is difficult to decide how the feature should fit into the existing communication between creatives, requesters, and their advisors. If added, the feature should also encapsulate the process of approving the design or production.
* Order statistics. I'm actively working on adding statistics throughout the app: how many orders did an organization make in the past __ months? How many orders were completed by each designer? What's the average length of time for the orders?

**Improvements to be made:**

* SQL Query performance is poor, especially during the process of authorization. Prudent use of joins() and refactoring Ability.rb is a good next step.
* Turbolinks-friendly JavaScript: although Fancybox is the only issue (when using the browser's back button and interacting with a cached page), all of the JavaScript should be reconsidered in the context of Turbolinks.


## Credits

As mentioned above, this project stems from a similar application by [Bill Columbia](http://billcolumbia.me) called DesignQ. DesignQ informed the basic structure of the application and forced members of the office to decide how the interactions should take place.

I, [AJ Foster](http://aj-foster.com), began developing CreativeQ in May 2014. My process - as well as many lessons about Rails - can be found within this repository. If you have any questions, comments, or concerns, please don't hesitate to contact me.
