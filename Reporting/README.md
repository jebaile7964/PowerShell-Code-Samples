# Reporting

#### GDI Handle Logger

This script is designed to record when the Spooler service's GDI handle count reaches its max of 10000.  The necessity for
such a script began when issues arose over certain printer drivers overloading the spooler when used to print from
Microsoft Report Viewer.  It was found that the Microsoft printing process involved rendering of GDI objects and sometimes
shotty drivers would crash the spooler.  After verifying that the Spooler service was crashing after it was overloaded by GDI
handles, a policy was set in place that restricted EMF printing, thus eliminating tickets regarding printing issues for our
Cloud customers.
