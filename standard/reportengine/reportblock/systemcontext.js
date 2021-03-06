/* reposyd-reportblock-header */
const Diagrams = require( 'reposyd-core' ).ReportFramework.Diagrams
const LexicographicalOrder = require( 'reposyd-core' ).Utils.LexicographicalOrder
const ReportBlock = require( 'reposyd-core' ).ReportFramework.ReportBlock
const ReportTable = require( 'reposyd-core' ).ReportFramework.ReportTable
const Rule = require( 'js-rules-engine' ).Rule
const Utils = require( 'reposyd-core' ).Utils
/* reposyd-reportblock-header */
class ReportBlockRequirements extends ReportBlock {
  constructor( section, engine ) {
    super( section, engine )
    /* reposyd-reportblock-constructor */
    this.definition = {
      tt: this.designDataObjectDefinition( 'TT' )
    }
    this.sectionNumber = new Utils.LexicographicalOrder.SectionNumber(section.number)
    /* reposyd-reportblock-constructor */
  }
  /* reposyd-reportblock-body */
  renderContent() {
    this.format.writeHtml( this.section.text )
    var diagrams = new Diagrams( this )
    diagrams.list( 'scd' ).forEach( dm => {
      this.renderDiagram( dm )
    } )
  }

  renderDiagram( dm ) {
    // this.writeHtml(dm.ddo.attributes.title, 'title')
    this.sectionNumber.add()
    this.addSection(this.sectionNumber.toString(), dm.ddo.attributes.title)
    this.writeImage( dm.svg, `Systemkontextdiagram: ${dm.ddo.attributes.title}` )
    this.writeHtml( dm.ddo.attributes.description, 'description' )

    this.sectionNumber.add()
    this.addSection(this.sectionNumber.toString(), 'Stakeholder')
    this.sectionNumber.add()
    // this.writeHtml( 'Stakeholder', 'title' )
    Utils.Sort.byAttributes( dm.designDataObjects( 'SR' ), ['title'] )
      .forEach( sr => {
        this.addSection(this.sectionNumber.toString(), sr.attributes.title)
        this.sectionNumber.inc()
        // this.writeHtml( sr.attributes.title, 'title' )
        this.writeHtml( sr.attributes.description, 'description' )
        this.writeHtml( `[${sr.puid}]`, 'puid' )

      } )
    this.sectionNumber.remove()
    this.sectionNumber.inc()
    this.addSection(this.sectionNumber.toString(), 'Externe Systeme')
    this.sectionNumber.add()
    // this.writeHtml( 'Externe Systeme', 'title' )
    dm.designDataObjects( 'SE' )
      .forEach( se => {
        if ( se.uuid !== dm.ddo.uuid ) {
          this.addSection(this.sectionNumber.toString(), se.attributes.title)
          this.sectionNumber.inc()
          // this.writeHtml( se.attributes.title, 'title' )
          this.writeHtml( se.attributes.description, 'description' )
          this.writeHtml( `[${se.puid}]`, 'puid' )
        }
      } )
      this.sectionNumber.remove()
      this.sectionNumber.inc()
      this.addSection(this.sectionNumber.toString(), 'Schnittstellenobjekte')
      this.sectionNumber.add()
      // this.writeHtml( 'Schnittstellenobjekte', 'title' )
      dm.designDataObjects( 'II' )
        .forEach( se => {
          if ( se.uuid !== dm.ddo.uuid ) {
            this.addSection(this.sectionNumber.toString(), se.attributes.title)
            this.sectionNumber.inc()
            // this.writeHtml( se.attributes.title, 'title' )
            this.writeHtml( se.attributes.description, 'description' )
            this.writeHtml( `[${se.puid}]`, 'puid' )
          }
        } )
    }

  renderRequirement( rt ) {
    this.addDesignData( 'ddo', rt.uuid )
    this.writeHtml( rt.attributes.number + ' ' + rt.attributes.title, 'title' )
    this.writeHtml( 'Anforderung', 'title' )
    this.writeHtml( rt.attributes.description, 'description' )
    this.writeHtml( 'Begründung', 'title' )
    if ( !this.writeHtml( rt.attributes.rationale, 'description' ) ) {
      this.writeHtml( 'Keine', 'description' )
    }
    this.writeHtml( 'Weitere Informationen', 'title' )
    var table = new ReportTable.Table( 1, 4 )
    table.horizontalHeader.style = 'tableHeader'
    table.horizontalHeader.addRow()
    table.horizontalHeader.setCaption( 0, 'Reifegrad' )
    table.horizontalHeader.setCaption( 1, 'Priorität' )
    table.horizontalHeader.setCaption( 2, 'PUID' )
    table.horizontalHeader.setCaption( 3, 'External ID' )
    table.style = ReportTable.Table.NoBorderStyle

    table.setData( 0, 0, rt.definition.attributes.maturitylevel.properties.enumeration.find( item => item.key === rt.attributes.maturitylevel ).value )
    table.setData( 0, 1, rt.definition.attributes.priority.properties.enumeration.find( item => item.key === rt.attributes.priority ).value )
    table.setData( 0, 2, rt.puid )
    table.setData( 0, 3, '' )
    this.writeTable( table )
  }
  renderVerification( tt ) {
    this.addDesignData( 'ddo', tt.uuid )
    this.writeHtml( 'Abnnahmetest', 'title' )
    this.writeHtml( 'Methode: ' + this.definition.tt.attributes.method.properties.enumeration.find( item => item.key === tt.attributes.method ).value )
    this.writeHtml( 'Umfang: ' + this.definition.tt.attributes.scope.properties.enumeration.find( item => item.key === tt.attributes.scope ).value )
    this.writeHtml( 'Abnahmekriterium', 'title' )
    this.writeHtml( tt.attributes.acceptancecriteria, 'description' )
    this.writeHtml( 'Testbeschreibung', 'title' )
    this.writeHtml( tt.attributes.description, 'description' )
  }
  renderRequirementsOnly() {
    var rule = new Rule( {
      or: [{
        fact: 'attributes.type',
        operator: 'in',
        value: [this.section.reportblock.options.reportblock['rt.attributes.type']]
      }]
    } )
    var list = []
    this.designDataObjects( 'RT' ).forEach( rt => {
      if ( rule === null ) {
        list.push( rt )
      } else {
        var match = rule.evaluate( rt )
        if ( match ) {
          list.push( rt )
        } else { }
      }
    } )
    list.sort( ( a, b ) => LexicographicalOrder.compare( a.attributes.number, b.attributes.number ) )
    list.forEach( rt => {
      this.addDesignData( rt )
      this.writeHtml( rt.attributes.number + ' ' + rt.attributes.title, 'title' )
      this.writeHtml( 'Anforderung', 'title' )
      this.writeHtml( rt.attributes.description, 'description' )
      this.writeHtml( 'Begründung', 'title' )
      if ( !this.writeHtml( rt.attributes.rationale, 'description' ) ) {
        this.writeHtml( 'Keine', 'description' )
      }
      this.writeHtml( 'Weitere Informationen', 'title' )
      var table = new ReportTable.Table( 2, 4 )
      table.style = ReportTable.Table.NoBorderStyle
      table.setData( 0, 0, 'Reifegrad' )
      table.setData( 0, 1, 'Priorität' )
      table.setData( 0, 2, 'PUID' )
      table.setData( 0, 3, 'External ID' )
      table.setData( 1, 0, rt.definition.attributes.maturitylevel.properties.enumeration.find( item => item.key === rt.attributes.maturitylevel ).value )
      table.setData( 1, 1, rt.definition.attributes.priority.properties.enumeration.find( item => item.key === rt.attributes.priority ).value )
      table.setData( 1, 2, rt.puid )
      table.setData( 1, 3, '' )
      this.writeTable( table )
    } )
  }
  renderRequirementsAndVerification() {
    var rule = new Rule( {
      or: [{
        fact: 'attributes.type',
        operator: 'in',
        value: [this.section.reportblock.options.reportblock['rt.attributes.type']]
      }]
    } )
    var list = []
    this.designDataLinks( 'RT', 'verifiedby', 'TT' ).forEach( item => {
      if ( rule === null ) {
        list.push( item )
      } else {
        var match = rule.evaluate( item.ddo )
        console.debug( match, item.ddo.attributes.type, this.section.reportblock.options.reportblock.rule )
        if ( match ) {
          list.push( item )
        }
      }
    } )
    list.sort( ( a, b ) => LexicographicalOrder.compare( a.ddo.attributes.number, b.ddo.attributes.number ) )
    list.forEach( item => {
      this.renderRequirement( item.ddo )
      item.ddl.forEach( link => {
        this.renderVerification( link.ddo )
      } )
    } )
  }
  /* reposyd-reportblock-body */
  static RuleDefinition( settings ) {
    var rule = ReportBlockRequirements.DefaultSettings( settings ).rule;
    return rule === undefined ? null : rule
  }
  static DefaultSettings( settings ) {
    return {
      /* reposyd-reportblock-settings */
      section: [{
        id: 'pageBreak',
        title: {
          'de-DE': 'Seitenumbruch',
          'en-US': 'Page Break'
        },
        type: 'boolean',
        value: false
      }],
      reportblock: [{
        id: 'rt.attributes.type',
        title: {
          'de-DE': 'Art der Anforderung',
          'en-US': 'Type of Requirement'
        },
        type: 'select',
        options: 'type@RT',
        selection: 'single',
        value: 'pending'
      },
      {
        id: 'verification',
        title: {
          'de-DE': 'Drucke Nachweisführung',
          'en-US': 'Print Verification'
        },
        type: 'boolean',
        value: false
      }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockRequirements
