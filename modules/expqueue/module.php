<?php
/**
 * The admin module "expqueue" (Setup > Job queue): the dashboard, the job list, a job, a group, and the actions
 * (pause/resume, cancel, requeue, a test job) which are POST only and checked by ezformtoken.
 *
 * Policies: expqueue/view (every page) and expqueue/manage (the actions). A new installation gives them only to the
 * Administrator role, which holds every policy. Pages take view parameters only, never GET parameters.
 */

$Module = array( 'name' => 'Job queue', 'variable_params' => false );

$ViewList = array();

$ViewList['dashboard'] = array(
    'default_navigation_part' => 'ezsetupnavigationpart',
    'script' => 'dashboard.php',
    'functions' => array( 'view' ),
    'params' => array() );

$ViewList['list'] = array(
    'default_navigation_part' => 'ezsetupnavigationpart',
    'script' => 'list.php',
    'functions' => array( 'view' ),
    'params' => array(),
    'unordered_params' => array( 'state' => 'State', 'class' => 'Class', 'type' => 'Type', 'resource' => 'Resource',
                                 'group' => 'Group', 'offset' => 'Offset' ) );

$ViewList['job'] = array(
    'default_navigation_part' => 'ezsetupnavigationpart',
    'script' => 'job.php',
    'functions' => array( 'view' ),
    'params' => array( 'UUID' ) );

$ViewList['group'] = array(
    'default_navigation_part' => 'ezsetupnavigationpart',
    'script' => 'group.php',
    'functions' => array( 'view' ),
    'params' => array( 'UUID' ),
    'unordered_params' => array( 'offset' => 'Offset' ) );

$ViewList['action'] = array(
    'default_navigation_part' => 'ezsetupnavigationpart',
    'script' => 'action.php',
    'functions' => array( 'manage' ),
    'params' => array() );

$FunctionList = array();
$FunctionList['view'] = array();
$FunctionList['manage'] = array();
